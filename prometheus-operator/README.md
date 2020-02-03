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
