export GRAFANA_PASSWORD?=nutanix/4u
export JOB_ITERATIONS?=10
export QPS?=10
export UUID?=${uuidgen}
export WORKLOAD?=cluster-density

operators:
	oc create -f https://download.elastic.co/downloads/eck/2.0.0/crds.yaml
	oc apply -f https://download.elastic.co/downloads/eck/2.0.0/operator.yaml
	oc new-project grafana
	oc create -f environment/grafana-operator.yaml
	sleep 60

instances:
	oc new-project elastic
	oc create -f environment/elasticsearch.yaml
	sleep 60

configure:
	export esPassword=$(shell oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
	export esRoute=$(shell oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
	envsubst < environment/grafana.yaml | oc create -f -
	sleep 60
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
	export BEARER_TOKEN=$(shell oc serviceaccounts get-token grafana-serviceaccount -n grafana)
	envsubst < environment/prometheus-grafanadatasource.yaml | oc create -f -
	envsubst < environment/elastic-grafanadatasource.yaml | oc create -f -
	oc create -f environment/grafana-dashboard.yaml

create_benchmark:
	oc new-project benchmark
	oc create sa benchmark
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z benchmark -n benchmark
run:
	promToken=$(shell oc serviceaccounts get-token benchmark -n benchmark)
	promRoute=$(shell oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
	esRoute=$(shell oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
	export esPassword=$(shell oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
	cd workload/$(WORKLOAD)/ && kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
