# Requirements:
Ceph cluster
https://github.com/evsq/linux/blob/master/guides/CEPH

Install ceph-common on each kubernetes worker node
sudo yum install ceph-common -y

# Create pool
sudo ceph osd pool create kube 100

# Get admin key
sudo ceph auth get-key client.admin

# Create admin key secret
kubectl create secret generic ceph-admin-key \
    --type="kubernetes.io/rbd" \
    --from-literal=key='enter key from command (sudo ceph auth get-key client.admin)' \
    --namespace=kube-system

# Create client for pool
sudo ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'

# Get client key
sudo ceph auth get-key client.kube

# Create client key secret
kubectl create secret generic ceph-client-key \
    --type="kubernetes.io/rbd" \
    --from-literal=key='enter key from command (sudo ceph auth get-key client.kube)' \
    --namespace=kube-system

# Deploy rbd-provisioner
kubectl apply -f rbd-provisioner.yaml

# Create storage class
kubectl apply -f ceph-storageclass.yaml

# Test ceph
kubectl apply -f test-app.yaml


