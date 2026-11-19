# NetworkMonitor Helm Chart

Deploys [NetworkMonitor](https://github.com/BaiMeow/NetworkMonitor) on Kubernetes, with optional embedded InfluxDB v2 uptime storage, BGP listener service, IoT server, OpenTelemetry tracing, and Ingress.

## Installation

### Add the Helm Repository

```bash
helm repo add baimeow https://baimeow.github.io/helm-charts
helm repo update
```

### Default (with embedded InfluxDB v2)

```bash
helm install network-monitor baimeow/network-monitor \
  --namespace network-monitor \
  --create-namespace \
  -f my-values.yaml
```

### Without InfluxDB (disable uptime tracking)

```bash
helm install network-monitor baimeow/network-monitor \
  --set influxdb.enabled=false
```

### With an External InfluxDB v2

```bash
helm install network-monitor baimeow/network-monitor \
  --set influxdb.embedded.enabled=false \
  --set influxdb.addr="http://influxdb.monitoring.svc.cluster.local:8086" \
  --set influxdb.org="network-monitor" \
  --set influxdb.token="your-influxdb-token"
```

Or using an existing Kubernetes Secret (`token` key):

```bash
helm install network-monitor baimeow/network-monitor \
  --set influxdb.embedded.enabled=false \
  --set influxdb.addr="http://influxdb.monitoring.svc.cluster.local:8086" \
  --set influxdb.org="network-monitor" \
  --set influxdb.existingSecret="my-influxdb-secret"
```

## Example `my-values.yaml`

```yaml
metadataRedirect: "https://metadata.dn11.baimeow.cn/monitor-metadata.json"

# Or provide inline monitor-metadata.json when metadataRedirect is empty:
# metadata:
#   metadata:
#     "4211110000":
#       display: "AS NAME"

probe:
  bgp1:
    fetch:
      type: bgp
      mode: listen
      asn: 4211110000
      router-id: 172.16.0.1
    parse:
      type: bgp
    draw:
      type: bgp
      name: bgp1
  AS1:
    fetch:
      type: http
      url: "http://endpoint"
      method: "GET"
    parse:
      type: bird-ospf
    draw:
      type: ospf
      asn: 4211110000

bgpService:
  enabled: true
  type: LoadBalancer
  externalTrafficPolicy: Local

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
  hosts:
    - host: monitor.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Key Parameters

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of NetworkMonitor replicas | `1` |
| `image.repository` | Container image repository | `ghcr.io/baimeow/network-monitor` |
| `image.tag` | Container image tag (defaults to `Chart.appVersion`) | `""` |
| `port` | Web server port inside container | `8787` |
| `interval` | Probe fetch interval in seconds | `10` |
| `probeTimeout` | Probe fetch timeout in seconds | `8` |
| `analysis` | Enable graph analysis endpoints | `true` |
| `metadataRedirect` | External URL to redirect `/monitor-metadata.json` | `""` |
| `metadata` | Inline `monitor-metadata.json` content (YAML map or JSON string) | `{}` |
| `probe` | Probe definitions (`fetch`, `parse`, `draw`) | `{}` |
| `uptime.storeDuration` | Uptime data retention duration | `"168h"` |
| `uptime.interval` | Uptime record interval in seconds | `20` |
| `uptime.skip` | Set `SKIP_UPTIME=true` | `false` |
| `influxdb.enabled` | Enable InfluxDB integration | `true` |
| `influxdb.embedded.enabled` | Deploy embedded InfluxDB v2 StatefulSet | `true` |
| `influxdb.embedded.persistence.enabled` | Enable PVC for embedded InfluxDB | `true` |
| `influxdb.embedded.persistence.size` | PVC storage size | `10Gi` |
| `influxdb.addr` | External InfluxDB URL (when `embedded.enabled=false`) | `""` |
| `influxdb.org` | InfluxDB organization | `"network-monitor"` |
| `influxdb.token` | InfluxDB API token (auto-generated for embedded if empty) | `""` |
| `influxdb.existingSecret` | Existing Secret holding InfluxDB credentials | `""` |
| `trace.endpoint` | OpenTelemetry OTLP gRPC endpoint | `""` |
| `trace.serviceName` | OpenTelemetry service name | `""` |
| `iot.enabled` | Enable IoT HTTP server | `false` |
| `iot.port` | IoT server port | `8788` |
| `pprof.enabled` | Enable Go pprof on port 8080 (`PPROF=1`) | `false` |
| `webService.type` | Web UI Service type | `ClusterIP` |
| `webService.port` | Web UI Service port | `80` |
| `bgpService.enabled` | Create BGP listener Service | `true` |
| `bgpService.type` | BGP Service type | `LoadBalancer` |
| `bgpService.port` | BGP Service port | `179` |
| `ingress.enabled` | Enable Ingress for Web UI | `false` |
