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

# Quickstart

```
wget https://github.com/cloud-bulldozer/kube-burner/releases/download/v0.15.1/kube-burner-0.15.1-Linux-x86_64.tar.gz
tar xzvf kube-burner-0.15.1-Linux-x86_64.tar.gz
sudo install kube-burner /usr/bin
```

```
git clone https://github.com/wolfganghuse/ocp-stress
cd ocp-stress
./deploy.sh
```

```
```

# Setup Logging/Visualization Backend

## Needed Operators
### Deploy ElasticSearch Operator
```
oc create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
oc apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml

```

### Deploy Grafana Operator
```
oc new-project grafana
oc create -f environment/grafana-operator.yaml

```

### Deploy ElasticSearch 7.12.1 with Route
```
oc new-project elastic
oc create -f environment/elasticsearch.yaml

```

## Grafana

### Deploy Grafana
```
export GRAFANA_PASSWORD=nutanix/4u
envsubst < environment/grafana.yaml | oc create -f -

```

Assign Grafana Account to Cluster Monitoring
```
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana

```
Export needed Tokens, Password and Route
```
export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n grafana)
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)

```

Create Datasources and Dashboard
```
envsubst < environment/prometheus-grafanadatasource.yaml | oc create -f -
envsubst < environment/elastic-grafanadatasource.yaml | oc create -f -
oc create -f environment/grafana-dashboard.yaml

```

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

Export Tokens, etc (only neccessary when running in another shell then used for installation)
```
export esPassword=export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
```

Additional needed Values for running our Workload
```
export JOB_ITERATIONS=100
export QPS=20
export UUID=$(uuidgen)
export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
```

Running the Test itself
```
cd workload/(desired test)
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
```

After running the Workloads, clean up a little bit
```
kube-burner destroy --uuid=${UUID}
```
