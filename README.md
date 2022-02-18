# Openshift Monitoring & Stress

## Why
Have a deployment for:

a) Data-Collection and Visualisation Backend

b) repeatable Deployment for Workloads

## How
- RedHat OpenShift 4.9
- ElasticSearch 7.12
- Prometheus
- Grafana 8.0
- kube-burner

# Prepare Environment

Openshift Cluster must be fully deployed with at least one Storage Class.
Do not use this on a Production Cluster until you know what you are doing. Using the wrong settings you can burn down the House.
# Setup Logging/Visualization Backend

## Needed Operators
- Deploy ElasticSearch Operator
- Deploy Grafana Operator

## ElasticSearch
### Deploy ElasticSearch 7.12.1 with Route
```
oc new-project elastic

cat <<EOF | oc create -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch
  namespace: elastic
spec:
  nodeSets:
    - name: default
      count: 1
      config:
        node.store.allow_mmap: false
  version: 7.12.1
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: elasticsearch
spec:
  tls:
    termination: passthrough
    insecureEdgeTerminationPolicy: Redirect
  to:
    kind: Service
    name: elasticsearch-es-http
EOF
```

## Grafana

### Deploy Grafana
```
cat <<EOF | oc create -f -
apiVersion: integreatly.org/v1alpha1
kind: Grafana
metadata:
  name: grafana
  namespace: grafana
spec:
  dashboardLabelSelector:
    - matchExpressions:
        - { key: app, operator: In, values: [grafana] }
  config:
    security:
      admin_password: nutanix/4u
      admin_user: root
    auth.basic:
      enabled: true
    auth:
      disable_signout_menu: true
  ingress:
    enabled: true
EOF
```

Grant Grafana access to cluster-monitoring
```
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
```

Create kube-burner Dashboard


- Deploy Prometheus Datasource

Get Service Account Token
```
export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n grafana)
```

```
cat <<EOF | oc create -f -
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: prometheus-grafanadatasource
  namespace: grafana
spec:
  datasources:
    - access: proxy
      editable: true
      isDefault: true
      jsonData:
        httpHeaderName1: 'Authorization'
        timeInterval: 5s
        tlsSkipVerify: true
      name: Prometheus
      secureJsonData:
        httpHeaderValue1: 'Bearer ${BEARER_TOKEN}'
      type: prometheus
      url: 'https://thanos-querier.openshift-monitoring.svc.cluster.local:9091'
  name: prometheus-grafanadatasource.yaml
EOF

```

- Deploy Elastic Datasource


```
cat <<EOF | oc create -f -
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: elastic-grafanadatasource
  namespace: grafana
spec:
  datasources:
    - jsonData:
        tlsSkipVerify: true
      editable: true
      name: kube-burner
      type: elasticsearch
      url: 'https://elasticsearch-elastic.apps.ocp1.ntnxlab.local'
      basicAuthPassword: ${esPassword}
      basicAuth: true
      basicAuthUser: elastic
  name: elastic-grafanadatasource.yaml
EOF
```  
- Deploy Grafana Dashboards (Openshift / Kube-Burner)

oc create -f environment/grafana-dashboard.yaml

## Setup Workloads
### kube-burner
Download the latest Release from kube-burner on your Workstation:

```
wget https://github.com/cloud-bulldozer/kube-burner/releases/download/v0.15.1/kube-burner-0.15.1-Linux-x86_64.tar.gz
tar xzvf kube-burner-0.15.1-Linux-x86_64.tar.gz
sudo install kube-burner /usr/bin
```

As an alternative you can also build the latest version from scratch, this may be needed when newest features (acutal patching) is not available in latest release
```
git clone https://github.com/cloud-bulldozer/kube-burner.git
sudo yum install -y make go
cd kube-burner
make build
sudo install  bin/amd64/kube-burner /usr/bin
```



### Prepare Benchmark Environment
```
oc new-project benchmark
oc create sa benchmark

oc adm policy add-cluster-role-to-user cluster-monitoring-view -z benchmark -n benchmark
```

## Run Test

```
export esPassword=export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
export JOB_ITERATIONS=100
export QPS=20
export UUID=$(uuidgen)

cd workload/(desired test)
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
```

After running the Workloads, clean up a little bit
```
kube-burner destroy --uuid=${UUID}
```
