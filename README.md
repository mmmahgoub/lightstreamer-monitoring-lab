# Lightstreamer Monitoring Lab

A Docker-based Lightstreamer monitoring stack with Prometheus and Grafana.
This repository runs Lightstreamer with a Prometheus Metrics Exporter adapter, scrapes exporter metrics, and provisions a Grafana dashboard for Lightstreamer visibility.

## Architecture

- `lightstreamer`: Lightstreamer server container
- `prometheus`: Prometheus server scraping Lightstreamer exporter metrics
- `grafana`: Grafana UI with provisioned Prometheus datasource and Lightstreamer dashboard
- `adapters/metrics_exporter`: Lightstreamer exporter adapter mounted into the Lightstreamer container

## Requirements

- Docker Engine
- Docker Compose
- Linux / macOS / Windows with Docker support

## Setup

1. Clone this repository.
2. Ensure the `adapters/metrics_exporter` directory contains the Lightstreamer exporter adapter.
3. Verify `docker-compose.yml`, `prometheus.yml`, and the Grafana provisioning files are present.

## Start


cd lightstreamer-monitoring-lab
docker compose -f docker-compose.yml up -d


This starts:

- Lightstreamer on `http://localhost:8080`
- Prometheus on `http://localhost:9090`
- Grafana on `http://localhost:3000`

## Grafana

Grafana is provisioned to use Prometheus as the default datasource.

- Grafana URL: `http://localhost:3000`
- Default admin password: `admin`
- Anonymous access is enabled with `Admin` role for convenience.
- Provisioned dashboard path: `grafana/dashboards/lightstreamer-dashboard.json`

If you change dashboard provisioning, restart Grafana with:


docker compose -f docker-compose.yml restart grafana


## Prometheus

Prometheus scrapes the Lightstreamer exporter at:

- `http://lightstreamer:9100`

Configured scrape interval: `5s`.

## Metrics Exporter

Lightstreamer exporter metrics are exposed on port `9100`.
Use Prometheus to query metrics such as:

- `lightstreamer_AdapterSet_CurrentSessions`
- `lightstreamer_Load_TotalPooledThreads`
- `lightstreamer_Load_ActivePooledThreads`
- `lightstreamer_Load_TotalPoolQueue`
- `lightstreamer_ThreadPool_Queue`
- `lightstreamer_ThreadPool_ActiveThreads`
- JVM and process metrics from the exporter

## Simulate Load

A helper script is included to simulate Lightstreamer sessions:


./session_generator.sh


This script creates multiple simulated Lightstreamer sessions and keeps them open for a short period.

## Files

- `docker-compose.yml` — defines Lightstreamer, Prometheus, and Grafana containers
- `prometheus.yml` — Prometheus scrape configuration
- `grafana/provisioning/datasources/prometheus.yml` — Grafana datasource provisioning
- `grafana/provisioning/dashboards/lightstreamer.yml` — Grafana dashboard provisioning
- `grafana/dashboards/lightstreamer-dashboard.json` — provisioned Grafana dashboard definition
- `session_generator.sh` — helper script to simulate Lightstreamer session activity

## Notes

- `grafana_dashboard.json` is currently empty; the actual provisioned dashboard is `grafana/dashboards/lightstreamer-dashboard.json`.
- If Grafana does not show data immediately, wait a minute for Prometheus to scrape Lightstreamer metrics and refresh Grafana.
- Use `docker compose -f docker-compose.yml logs -f prometheus grafana lightstreamer` to troubleshoot.

## License

Use and modify as needed for your monitoring lab.
