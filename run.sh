export JOB_ITERATIONS=10
export QPS=20
export WORKLOAD=cluster-density
export UUID=$(uuidgen)
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)

export esServer=https://elastic:$esPassword@$esRoute

export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc create token benchmark -n benchmark)
cd workload/${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
