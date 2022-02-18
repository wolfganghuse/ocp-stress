export JOB_ITERATIONS=10
export QPS=20
export WORKLOAD=cluster-density
export UUID=$(uuidgen)
export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
cd workload/${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
