# Usage

Optional: if you want to gain Prometheus full access to kubelet, then add flags in kubelet below

```
--authentication-token-webhook=true
--authorization-mode=Webhook
```

Install CRD

```
kubectl create -f manifests/setup
```

Wait until crd created

```
sleep 10
```

Install monitoring components for prometheus-operator

```
kubectl create -f manifests/
```

# Monitoring external ETCD cluster

Create secrets with certs to allow Prometheus scrape metrics from ETCD

```
kubectl -n monitoring create secret generic etcd-certs --from-file=/tmp/prom-certs/etcd-ca.crt --from-file=/tmp/prom-certs/prometheus.key --from-file=/tmp/prom-certs/prometheus.crt
```

Create Service

```
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: etcd
  name: etcd
  namespace: monitoring
spec:
  clusterIP: None
  ports:
  - name: metrics
    port: 2379
    targetPort: 2379
```

Create Endpoints

```
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    k8s-app: etcd
  name: etcd
  namespace: monitoring
subsets:
- addresses:
  - ip: 10.20.0.2
    nodeName: etcd0
  - ip: 10.20.0.3
    nodeName: etcd1 
  - ip: 10.20.0.4
    nodeName: etcd2
  ports:
  - name: metrics
    port: 2379
    protocol: TCP
```

Create ServiceMonitor

Note: If you have multiple etcd nodes, then you need to add flag "insecureSkipVerify: true", as valid name for certificate will be different, thus you cannot add multiple names into flag "serverName:" 
If you have one etcd node, you need to remove flag "insecureSkipVerify: true" and type correct valid name certificate in "serverName:"

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: etcd
  name: etcd
  namespace: monitoring
spec:
  endpoints:
  - interval: 30s
    port: metrics
    scheme: https
    tlsConfig:
      caFile: /etc/prometheus/secrets/etcd-certs/etcd-ca.crt
      certFile: /etc/prometheus/secrets/etcd-certs/prometheus.crt
      keyFile: /etc/prometheus/secrets/etcd-certs/prometheus.key
      insecureSkipVerify: true
      serverName: etcd
  jobLabel: k8s-app
  selector:
    matchLabels:
      k8s-app: etcd
```

Update Prometheus

Add secrets in Prometheus spec 

```
secrets:
  - etcd-certs
```

For example

```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  labels:
    prometheus: k8s
  name: k8s
  namespace: monitoring
spec:
  alerting:
    alertmanagers:
    - name: alertmanager-main
      namespace: monitoring
      port: web
  baseImage: quay.io/prometheus/prometheus
  nodeSelector:
    beta.kubernetes.io/os: linux
  replicas: 2
  resources:
    requests:
      memory: 400Mi
  ruleSelector:
    matchLabels:
      prometheus: k8s
      role: alert-rules
  secrets:
  - etcd-certs
  serviceAccountName: prometheus-k8s
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector: {}
  version: v2.4.2
  ```

# Monitoring external masters

Install node exporter on masters VM. Use bash script in master directory

```
chmod u+x master/node_exporter.sh
./node_exporter.sh
```

Create Service

```
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: master-node-exporter
  name: master-node-exporter
  namespace: monitoring
spec:
  clusterIP: None
  ports:
  - name: metrics
    port: 9100
    targetPort: 9100
```

Create Endpoints

```
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    k8s-app: master-node-exporter
  name: master-node-exporter
  namespace: monitoring
subsets:
- addresses:
  - ip: 10.20.0.2
    nodeName: master0
  - ip: 10.20.0.3
    nodeName: master1 
  - ip: 10.20.0.4
    nodeName: master2
  ports:
  - name: metrics
    port: 9100
    protocol: TCP
```

Create ServiceMonitor

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: master-node-exporter
  name: master-node-exporter
  namespace: monitoring
spec:
  endpoints:
  - interval: 5s
    port: metrics
    scheme: http
  jobLabel: k8s-app
  selector:
    matchLabels:
      k8s-app: master-node-exporter
```

Add node exporter dashboard for Grafana

```
id 1860
```