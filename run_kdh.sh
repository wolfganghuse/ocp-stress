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
export JOB_ITERATIONS=25
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=50
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=75
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=100
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=125
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=150
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=175
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=200
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=225
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=250
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}
export UUID=$(uuidgen)
export JOB_ITERATIONS=275
kube-burner init -c workload.yml -u https://${promRoute} -t ${promToken} --step=30s -m metrics.yaml --uuid=${UUID} --log-level=info
kube-burner destroy --uuid=${UUID}