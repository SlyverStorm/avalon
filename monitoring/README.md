# Grafana Dashboard

## Grafana setup
Once Grafana is running:

1. Go to Connections → Data sources → Add data source.
    - Type: Prometheus
    - URL: http://prometheus:9090

2. Import dashboards:
    - Node Exporter Full → ID: `1860`
    - Docker + cAdvisor → ID: `893`