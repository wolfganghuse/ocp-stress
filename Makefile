export GRAFANA_PASSWORD=nutanix/4u


create_benchmark:
	oc new-project elastic
	oc create -f environment/elasticsearch.yaml
	export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
	oc new-project grafana
	oc create -f environment/grafana-operator.yaml
	envsubst < environment/grafana.yaml | oc create -f -
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
	export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n grafana)
	envsubst < environment/prometheus-grafanadatasource.yaml | oc create -f -
	envsubst < environment/elastic-grafanadatasource.yaml | oc create -f -
	oc create -f environment/grafana-dashboard.yaml
	oc new-project benchmark
	oc create sa benchmark
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z benchmark -n benchmark
run:
	export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
	export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
	export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
	cd workload/cluster-density/
	kube-burner init -c cluster-density.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
