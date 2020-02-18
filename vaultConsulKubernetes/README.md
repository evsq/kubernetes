Install CFSSL
```
go get -u github.com/cloudflare/cfssl/cmd/cfssl
go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```

Create CA
```
cfssl gencert -initca certs/ca-csr.json | cfssljson -bare certs/ca
```

Create key/certs for Consul
```
cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/ca-config.json \
    -profile=default \
    certs/consul-csr.json | cfssljson -bare certs/consul
```

Create key/certs for Vault
```
cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/ca-config.json \
    -profile=default \
    certs/vault-csr.json | cfssljson -bare certs/vault
```

Consul

Install Consul client
```
curl -LO https://releases.hashicorp.com/consul/1.7.0/consul_1.7.0_linux_amd64.zip
unzip consul_1.7.0_linux_amd64.zip
mv consul /usr/bin/
```

Create secret for Consul

```
export GOSSIP_ENCRYPTION_KEY=$(consul keygen)
```
```
kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem
```

Create configmap for Consul
```
kubectl create -f consul/configmap.yaml
```

Create service for Consul
```
kubectl create -f consul/service.yaml
```

Create statefulset for Consul
```
kubectl create -f consul/statefulset.yaml
```

Vault

Create secret for Vault
```

kubectl create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem
```

Create configmap for Vault
```
kubectl create -f vault/configmap.yaml
```

Create service for Vault
```
kubectl create -f vault/service.yaml
```

Create deployment for Vault
```
kubectl create -f vault/deployment.yaml
```

Access to Consul
```
kubectl port-forward consul-0 8500
```

Access to Vault
```

kubectl port-forward vault-bf9b69559-z82b8 8200
```

Test
```
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT="certs/ca.pem" 
```

```
vault operator init -key-shares=1 -key-threshold=1
vault operator unseal
vault login
vault kv put secret test=123
vault kv get secret
```