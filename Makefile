export GRAFANA_PASSWORD=nutanix/4u


create_benchmark:
	oc new-project elastic
	oc create -f environment/elasticsearch.yaml
	export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
	oc create -f environment/grafana.yaml
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
	export BEARER_TOKEN=$(oc serviceaccounts get-token grafana-serviceaccount -n grafana)
	oc create -f environment/prometheus-grafanadatasource.yaml
	oc create -f environment/elastic-grafanadatasource.yaml
	oc new-project benchmark
	oc create sa benchmark
	oc adm policy add-cluster-role-to-user cluster-monitoring-view -z benchmark -n benchmark
run:
	export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
	kube-burner init -c cluster-density.yml -u https://prometheus-k8s-openshift-monitoring.apps.ocp2.ntnxlab.local -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info

