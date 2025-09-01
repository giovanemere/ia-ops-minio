# 📊 Monitoreo

## Métricas Básicas

### Health Checks
```bash
# Verificar servicios
curl http://localhost:6540/health
curl http://localhost:8848/health
curl http://localhost:9898/minio/health/live
```

### Estadísticas del Sistema
```bash
# Uso de recursos
docker stats ia-ops-minio-portal

# Espacio en disco
df -h /data

# Memoria y CPU
htop
```

## Prometheus Integration

### Configuración MinIO
```bash
# Habilitar métricas de Prometheus
export MINIO_PROMETHEUS_AUTH_TYPE="public"
export MINIO_PROMETHEUS_URL="http://localhost:9090"
```

### prometheus.yml
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'minio'
    static_configs:
      - targets: ['localhost:9898']
    metrics_path: /minio/v2/metrics/cluster
```

## Grafana Dashboards

### MinIO Dashboard
- **Panel 1**: Uptime y disponibilidad
- **Panel 2**: Throughput (requests/sec)
- **Panel 3**: Latencia de requests
- **Panel 4**: Uso de almacenamiento
- **Panel 5**: Número de objetos por bucket

### Alertas
```yaml
groups:
  - name: minio
    rules:
      - alert: MinIODown
        expr: up{job="minio"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "MinIO is down"
```

## Logs Centralizados

### ELK Stack
```yaml
version: '3.8'
services:
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
  
  logstash:
    image: logstash:7.14.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
  
  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
```

## Alertas Automáticas

### Slack Notifications
```python
import requests
import json

def send_slack_alert(message):
    webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    payload = {
        "text": f"🚨 MinIO Alert: {message}",
        "channel": "#alerts",
        "username": "MinIO Monitor"
    }
    requests.post(webhook_url, data=json.dumps(payload))
```

### Email Alerts
```bash
#!/bin/bash
# email-alert.sh

SUBJECT="MinIO Alert"
TO="admin@example.com"
MESSAGE="$1"

echo "$MESSAGE" | mail -s "$SUBJECT" "$TO"
```
