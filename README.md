# Openshift Monitoring & Stress

## Why
Have a deployment for:
a) Data-Collection and Visualisation Backend
b) repeatable Deployment for Workloads

## How
RedHat OpenShift 4.9
ElasticSearch 7.2
Prometheus
Grafana 8.0
kube-burner

# Prepare Environment
Depending on your needs you can run Logging and Workloads on dedicated or the same Cluster.
Openshift Cluster must be fully deployed with at least one Storage Class.


# Setup Logging/Visualization Backend

## ElasticSearch
- Deploy ElasticSearch Operator
### Deploy ElasticSearch 7.12.1 with Route
'''
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
'''
### Get elastic User Credential
'''
oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}'
'''
## Grafana


https://www.redhat.com/en/blog/custom-grafana-dashboards-red-hat-openshift-container-platform-4


- Deploy Grafana Operator
### Deploy Grafana
'''
apiVersion: integreatly.org/v1alpha1
kind: Grafana
metadata:
  name: grafana
  namespace: grafana
spec:
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
'''

Grant Grafana access to cluster-monitoring
'''
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
'''

- Deploy Prometheus Datasource

Get Service Account Token
'''
oc serviceaccounts get-token grafana-serviceaccount -n grafana
'''

'''
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
        httpHeaderValue1: 'Bearer {BEARER_TOKEN}'
      type: prometheus
      url: 'https://thanos-querier.openshift-monitoring.svc.cluster.local:9091'
  name: prometheus-grafanadatasource.yaml
'''

- Deploy Elastic Datasource


'''
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
      type: elastic
      url: 'https://elasticsearch-elastic.apps.ocp1.ntnxlab.local'
      basicAuthPassword: {Your elastic cred}
      basicAuth: true
      basicAuthUser: elastic
  name: elastic-grafanadatasource.yaml
'''  
- Deploy Grafana Dashboards (Openshift / Kube-Burner)

# Setup Workloads
## kube-burner
https://github.com/cloud-bulldozer/kube-burner


# Setup Workload

'''
git clone https://github.com/cloud-bulldozer/benchmark-operator
cd benchmark-operator/charts/benchmark-operator
oc new-project benchmark-operator
oc adm policy -n benchmark-operator add-scc-to-user privileged -z benchmark-operator
helm install benchmark-operator .
'''

Create RBAC-Roles for kube-burner
'''
oc create -f https://raw.githubusercontent.com/cloud-bulldozer/benchmark-operator/master/resources/kube-burner-role.yml
'''

