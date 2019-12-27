Ingress + HAproxy on kubernetes bare metal cluster

Installation

You can install haproxy on your kubernetes nodes or create another one VM. I'll install haproxy on my first node in cluster

# Install HAproxy

yum install haproxy -y

# Export ip of your nodes in variables. Find your nodes ip, best way use "kubectl get nodes -o wide"

export nodeIP1=10.30.0.6
export nodeIP2=10.30.0.7

cat <<EOF > /etc/haproxy/haproxy.cfg
frontend main
  bind *:80
  default_backend nginx

backend nginx
  balance roundrobin
  server node1 ${nodeIP1}:80
  server node2 ${nodeIP2}:80
EOF

systemctl enable --now haproxy

# Install nginx ingress controller

kubectl apply -f nginx-inc-ingress/ns-and-sa.yaml
kubectl apply -f nginx-inc-ingress/default-server-secret.yaml
kubectl apply -f nginx-inc-ingress/nginx-config.yaml
kubectl apply -f nginx-inc-ingress/custom-resource-definitions.yaml
kubectl apply -f nginx-inc-ingress/rbac.yaml
kubectl apply -f nginx-inc-ingress/nginx-ingress.yaml

# Test ingress

# Create deployments and services


cat <<EOF > hello-app1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-app1
  template:
    metadata:
      labels:
        app: hello-app1
    spec:
      containers:
      - name: hello-app1
        image: hashicorp/http-echo
        ports:
        - containerPort: 8080
        args:
          - "-text=hello from app1"
          - "-listen=:8080"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-app1
spec:
  selector:
    app: hello-app1
  ports:
    - port: 8080
EOF

cat <<EOF > hello-app2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-app2
  template:
    metadata:
      labels:
        app: hello-app2
    spec:
      containers:
      - name: hello-app2
        image: hashicorp/http-echo
        ports:
        - containerPort: 8080
        args:
          - "-text=hello from app2"
          - "-listen=:8080"
---
apiVersion: v1
kind: Service
metadata:
  name: hello-app2
spec:
  selector:
    app: hello-app2
  ports:
    - port: 8080
EOF

kubectl apply -f hello-app1.yaml
kubectl apply -f hello-app2.yaml

# Create Ingress rule

cat <<EOF > hello-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
spec:
  rules:
  - host: hello.com
    http:
      paths:
      - backend:
          serviceName: hello-app1
          servicePort: 8080
        path: /
      - backend:
          serviceName: hello-app2
          servicePort: 8080
        path: /app2
EOF

kubectl apply -f hello-ingress.yaml

# If you don't have a DNS, then type external ip your VM where ran HAproxy and name your host (in my case hello.com) that will be use for access to app.

echo "1.2.3.4 hello.com" >> /etc/hosts

curl hello.com
curl hello.com/app2