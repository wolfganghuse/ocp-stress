export JOB_ITERATIONS=2
export QPS=20
export WORKLOAD=cluster-density
export UUID=$(uuidgen)
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)

export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)
cd workload/${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid ${UUID}

export JOB_ITERATIONS=15
export QPS=20
export WORKLOAD=cluster-density
cd ../${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid ${UUID}

export JOB_ITERATIONS=60
export QPS=20
export WORKLOAD=kubelet-csi-density-heavy
cd ../${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid ${UUID}

export JOB_ITERATIONS=300
export QPS=40
export WORKLOAD=api-intensive
cd ../${WORKLOAD}
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid ${UUID}