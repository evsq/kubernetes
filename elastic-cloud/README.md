Create namespace logging
```
kubectl create ns logging
```

Deploy CRDs
```
kubectl -f crds.yaml
```

After elastic-operator has status Running deploy elastic
```
kubectl -f elastic.yaml
```

Deploy kibana
```
kubectl -f kibana.yaml
```

Deploy filebeat

You need to change parameters below in filebeat.yaml , if you made any changes
```
        - name: ELASTICSEARCH_HOST
          value: https://quickstart-es-http
        - name: ELASTICSEARCH_PORT
          value: "9200"
        - name: ELASTICSEARCH_USERNAME
          value: elastic
        - name: ELASTICSEARCH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: quickstart-es-elastic-user
              key: elastic
```

```
kubectl apply -f filebeat.yaml
```

Test

Get a password to log in kibana
```
kubectl get secret -n logging quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 -d
```

Use port-forward to access Kibana and enter "elastic" in user field, enter password you received from secret above

```
kubectl port-forward -n logging service/quickstart-kb-http 5601
```

Create index pattern

Go to Management -> Kibana -> Index Patterns -> Create index pattern -> enter "filebeat" in index pattern field -> choose "@timestamp" in time filter time name field
Go to Discover -> enter "kubernetes..." and choose further options, for example kubernetes.pod.name:"elastic-operator-0", choose timestamp and click Refresh