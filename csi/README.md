# Deploy Nutanix CSI Operator on RedHat Openshift 

oc new-project ntnx-system


oc create secret generic ntnx-secret -n ntnx-system --from-literal=key=$(echo -n "10.0.00.000:9440:admin:mypassword" | base64)
oc create secret generic ntnx-secret -n ntnx-system --from-literal=key=$(echo -n "10.38.173.37:9440:admin:nx2Tech100!" | base64)

oc create -f operatorgroup.yaml
oc create -f subscription.yaml

oc create -f instance.yaml

oc create -f storageclass.yaml

