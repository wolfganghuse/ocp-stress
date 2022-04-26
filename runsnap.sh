export JOB_ITERATIONS=20
export QPS=10
export WORKLOAD=kubelet-csi-density-heavy
export UUID=$(uuidgen)
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)

export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
cd workload/${WORKLOAD}
kube-burner init -c snapshot.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info