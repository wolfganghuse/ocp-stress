GRAFANA_PASSWORD?=nutanix/4u
export JOB_ITERATIONS?=10
export QPS?=10
export UUID?=${shell uuidgen}
export WORKLOAD?=cluster-density

oc create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
oc apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml
oc new-project grafana
oc create -f environment/grafana-operator.yaml
sleep 60

oc new-project elastic
oc create -f environment/elasticsearch.yaml
sleep 60

envsubst < environment/grafana.yaml | oc create -f -
sleep 60
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n grafana)
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)

envsubst < environment/prometheus-grafanadatasource.yaml | oc create -f -
envsubst < environment/elastic-grafanadatasource.yaml | oc create -f -
oc create -f environment/grafana-dashboard.yaml

oc new-project benchmark
oc create sa benchmark
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z benchmark -n benchmark
exit

export promToken=$(shell oc serviceaccounts get-token benchmark -n benchmark)
export promRoute=$(shell oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host) 

cd workload/$(WORKLOAD)
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info