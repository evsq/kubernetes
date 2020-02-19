Deploy postgres-operator

Apply the manifests in the following order
```
kubectl create -f configmap.yaml
kubectl create -f operator-service-account-rbac.yaml
kubectl create -f postgres-operator.yaml
```

Deploy postgresql
```
kubectl create -f postgres.yaml
```
