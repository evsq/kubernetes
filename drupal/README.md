You need to create dir /data in your worker node for PV

kubectl create secret generic mysql \
> --from-literal=MYSQL_ROOT_PASSWORD=root_password \
> --from-literal=MYSQL_DATABASE=drupal-database
