# Openshift Monitoring & Stress

## Why
Have a deployment for:
a) Data-Collection and Visualisation Backend
b) repeatable Deployment for Workloads

## How
RedHat OpenShift 4.9
ElasticSearch 7.2
Prometheus
Grafana 8.0
kube-burner

# Prepare Environment
Depending on your needs you can run Logging and Workloads on dedicated or the same Cluster.
Openshift Cluster must be fully deployed with at least one Storage Class.


# Setup Logging/Visualization Backend

## ElasticSearch
- Deploy ElasticSearch Operator
- Deploy ElasticSearch 7.2 with Route

## Grafana
- Deploy Grafana Operator
- Deploy Grafana
- Deploy Prometheus Datasource
- Deploy Elastic Datasource
- Deploy Grafana Dashboards (Openshift / Kube-Burner)

# Setup Workloads
## kube-burner
https://github.com/cloud-bulldozer/kube-burner


# Setup Workload
