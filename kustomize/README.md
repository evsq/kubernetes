# Render resources to file
kubectl kustomize > test.yaml

# Render and apply resources to k8s
kubectl apply -k somedir
