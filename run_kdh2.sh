#Init
export esPassword=$(oc get secret -n elastic elasticsearch-es-elastic-user  -o go-template='{{.data.elastic | base64decode}}')
export esRoute=$(oc get route  -n elastic elasticsearch --no-headers -o custom-columns=NAME:.spec.host)
export promRoute=$(oc get route  -n openshift-monitoring prometheus-k8s --no-headers -o custom-columns=NAME:.spec.host)
export promToken=$(oc serviceaccounts get-token benchmark -n benchmark)

#Workload Init
export QPS=20
export WORKLOAD=kubelet-density-heavy
cd workload/${WORKLOAD}

export UUID=$(uuidgen)

#Workload Run
export UUID=$(uuidgen)
export JOB_ITERATIONS=300
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=350
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=400
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=450
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=500
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=550
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=600
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
