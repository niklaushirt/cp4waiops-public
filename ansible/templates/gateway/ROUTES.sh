mkdir -p /tmp/cluster-ca-cert
oc extract secret/signing-key -n openshift-service-ca --to=/tmp/cluster-ca-cert --keys=tls.crt --confirm

mkdir -p /tmp/omni-secret
oc extract secret/evtmanager-omni-secret  -n noi --confirm --to=/tmp/omni-secret 

oc delete secret -n cp4waiops evtmanager-omni-secret
oc create secret generic -n cp4waiops evtmanager-omni-secret --from-literal=username=root --from-file=password=/tmp/omni-secret/OMNIBUS_ROOT_PASSWORD

oc delete configmap -n cp4waiops emg-omni-ca
oc create configmap -n cp4waiops emg-omni-ca --from-file=rootca-primary.crt=/tmp/cluster-ca-cert/tls.crt --from-file=service-ca.crt=/tmp/cluster-ca-cert/tls.crt
oc create configmap -n cp4waiops emg-omni-ca --from-file=rootca-primary.crt=/tmp/cluster-ca-cert/tls-primary.crt --from-file=rootca-backup.crt=/tmp/cluster-ca-cert/tls-backup.crt

service-ca.crt




PRIMARY_SVC_IP=$(oc get pod -n noi evtmanager-ncoprimary-0 --output=jsonpath='{.status.hostIP}')
BACKUP_SVC_IP=$(oc get pod -n noi evtmanager-ncobackup-0 --output=jsonpath='{.status.hostIP}')
PROXY_SVC_IP=$(oc get pod -n noi -l app.kubernetes.io/name==proxy --output=jsonpath='{.items[0].status.hostIP}')


oc get svc -n noi evtmanager-objserv-agg-primary --output=jsonpath='{.spec.clusterIP}'

echo "PRIMARY_SVC_IP:  $PRIMARY_SVC_IP"
echo "BACKUP_SVC_IP:   $BACKUP_SVC_IP"
echo "PROXY_SVC_IP:    $PROXY_SVC_IP"


PRIMARY_SVC_IP:  10.196.124.184
BACKUP_SVC_IP:   10.196.143.232
PROXY_SVC_IP:    10.196.124.184


apiVersion: v1
kind: Service
metadata:
  name: evtmanager-ncoprimary-externalip
  namespace: noi
spec:
  ports:
  - name: iduc
    port: 4101
  externalTrafficPolicy: Cluster
  externalIPs:
  - 10.196.124.184
  type: LoadBalancer
  selector:
      app.kubernetes.io/name: ncoprimary

apiVersion: v1
kind: Service
metadata:
  name: evtmanager-ncobackup-externalip
  namespace: noi
spec:
  ports:
  - name: iduc
    port: 4101
  externalTrafficPolicy: Cluster
  externalIPs:
  - 10.196.143.232
  type: LoadBalancer
  selector:
      app.kubernetes.io/name: ncoprimary

apiVersion: v1
kind: Service
metadata:
  name: evtmanager-proxy-externalip
spec:
  ports:
  - name: tds-pri
    port: 6001
  - name: tds-bak
    port: 6002
  externalTrafficPolicy: Cluster
  externalIPs:
  - 10.196.124.184
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: proxy









































kubectl get service -o yaml evtmanager-proxy -n noi
oc get svc -n noi evtmanager-objserv-agg-primary evtmanager-objserv-agg-backup evtmanager-proxy



PRIMARY_SVC_IP=$(oc get pod -n noi evtmanager-ncoprimary-0 --output=jsonpath='{.status.hostIP}')
BACKUP_SVC_IP=$(oc get pod -n noi evtmanager-ncobackup-0 --output=jsonpath='{.status.hostIP}')
PROXY_SVC_IP=$(oc get pod -n noi -l app.kubernetes.io/name==proxy --output=jsonpath='{.items[0].status.hostIP}')


oc get pod -n noi evtmanager-ncoprimary-0 --output=jsonpath='{.status.hostIP}'
oc get pod -n noi evtmanager-ncobackup-0 --output=jsonpath='{.status.hostIP}'

netcat -v netcool-evtmanager.itzroks-270003bu3k-6dlioy-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud 4101 6001 6002

openssl s_client -showcerts -connect netcool-evtmanager.itzroks-270003bu3k-6dlioy-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud




   apiVersion: v1
      kind: Service
      metadata:
        name: evtmanager-ncobackup-externalip
      spec:
        ports:
        - name: iduc
          port: 4101
        externalTrafficPolicy: Cluster
2 of 12 10/26/21, 7:05 AM
EventManagerGateway configuration · hdm/nco-integrations-tracking Wiki https://github.ibm.com/hdm/nco-integrations-tracking/wiki/EventManag...
externalIPs:
      - <BACKUP_SVC_IP>
      type: LoadBalancer
      selector:
        app.kubernetes.io/name: ncobackup
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: evtmanager-proxy-externalip
    spec:
      ports:
      - name: tds-pri
        port: 6001
      - name: tds-bak
        port: 6002
      externalTrafficPolicy: Cluster
      externalIPs:
      - <PROXY_SVC_IP>
      type: LoadBalancer
      selector:
        app.kubernetes.io/name: proxy


netcat -v 141.125.76.236 4101