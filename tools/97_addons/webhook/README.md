# A Simple Webhook to Kafka Deployment for CP4WAIOPS AIManager



A Simple Webhook to Kafka Gateway for CP4WAIOPS.
This allows you to push generic JSON to AIManager Events throught a Webhook into Kafka.

> Source code is included if you want to mess around a bit.


## Usage

### Accessing the Web UI

You can access the Web UI via the external Route that you can determine like this:

```bash   
oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}
```

You have to use the Token to access the UI.


### Using the Webhook

The Webhook API is available at `http://<YOUR-CLUSTER>/webhook`

It has to be called with the `POST` Method and the security `token` (defined in the ConfigMap) has to be provided in the Header.

By default a dummy Mapping is being used, with the fields mapping to their target name in AI Manager (Node, NodeAlias, AlertGroup, ...).
Other Mappings (at the end of this documentation) can be defined by modifying the ConfigMap.

For the following example we will iterate over the `events` array and epush them to mapped version to Kafka:


```bash
curl -X "POST" "http://<YOUR-CLUSTER>/webhook" \
  -H 'token: my-token' \
  -H 'Content-Type: application/json; charset=utf-8' \
  -d $'{
"events": [
  {
    "URL": "https://pirsoscom.github.io/git-commit-robot.html",
    "Manager": "Github",
    "Severity": 2,
    "Summary": "[Git] Commit in repository robot-shop by Niklaus Hirt on file robot-shop.yaml - New Memory Limits",
    "Node": "mysql-github",
    "NodeAlias": "github",
    "AlertGroup": "robot-shop"
  },
  {
    "URL": "https://pirsoscom.github.io/INSTANA_CHANGE_ROB.html",
    "Manager": "Instana",
    "Severity": 3,
    "Summary": "[Instana] MySQL - change detected - The value **resources/limits** has changed",
    "Node": "mysql-instana",
    "NodeAlias": "mysql",
    "AlertGroup": "robot-shop"
  },
  {
    "URL": "none",
    "Manager": "Security",
    "Severity": 2,
    "Summary": "[Security] MySQL K8s Pod Created",
    "Node": "mysql-security",
    "NodeAlias": "mysql",
    "AlertGroup": "robot-shop"
  }
],
"numberOfEvents": 3
}'
```






## Automated Deployment

The easiest way to deploy the webhook is by using the automated Ansible script.

```bash   
ansible-playbook ./ansible/19_aimanager-event-webhook.yaml 

oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}
```

## Manual Deployment

### Message mapping Parameters

Those Strings define how the message is being decoded.

To adapt the mapping parameters to your needs, you have to modify in the `cp4waiops-event-gateway-config` ConfigMap in file `./tools/97_addons/webhook/create-cp4mcm-event-gateway.yaml`.


The following paramters have to be mapped:

```yaml
ITERATE_ELEMENT: 'events'
NODE_ELEMENT: 'kubernetes.container_name'
ALERT_ELEMENT: 'kubernetes.namespace_name'
SUMMARY_ELEMENT: '@rawstring'
TIMESTAMP_ELEMENT: '@timestamp'
URL_ELEMENT: 'none'
SEVERITY_ELEMENT: '5'
MANAGER_ELEMENT: 'KafkaWebhook'
```

1. The `ITERATE_ELEMENT` is the element of the Message that we iterate over.
	This means that the Gateway will get the `ITERATE_ELEMENT`element and iterate, map and push all messages in the array.
1. The sub-elements that will be mapped for each element in the array are:

	- Node
	- AlertGroup
	- Summary
	- URL
	- Severity
	- Manager
	- Timestamp

> Any element that cannot be found will be defaulted by the indicated value.
> Example for Severity: If we put the mapping value "5" in the config, this probably won't correspond to a JSON key and the severity for all messages is forced to 5.

> Exception is `Timestamp` which, when not found will default to the current EPOCH date.





### Getting the Kafka Conncetion Parameters

This gives you the Parameters for the Kafka Connection that you have to modify in the `cp4waiops-event-gateway-config` ConfigMap in file `./tools/97_addons/webhook/create-cp4mcm-event-gateway.yaml`.

```bash
export WAIOPS_NAMESPACE=cp4waiops
export KAFKA_TOPIC_EVENTS=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep -v cp4waiopscp4waiops|grep -v noi-integration | grep cp4waiops-cartridge-alerts-$EVENTS_TYPE| awk '{print $1;}')
export KAFKA_TOPIC_LOGS=$(oc get kafkatopics -n $WAIOPS_NAMESPACE  | grep -v cp4waiopscp4waiops| grep cp4waiops-cartridge-logs-elk| awk '{print $1;}')
export KAFKA_SECRET=$(oc get secret -n $WAIOPS_NAMESPACE |grep 'aiops-kafka-secret'|awk '{print$1}')
export KAFKA_USER=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export KAFKA_PWD=$(oc get secret $KAFKA_SECRET -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443
export CERT_ELEMENT=$(oc get secret -n $WAIOPS_NAMESPACE kafka-secrets  -o 'go-template={{index .data "ca.crt"}}'| base64 -d)
export TOKEN=123456789

echo "KAFKA_BROKER: '"$KAFKA_BROKER"'"
echo "KAFKA_USER: '"$KAFKA_USER"'"
echo "KAFKA_PWD: '"$KAFKA_PWD"'"
echo "KAFKA_TOPIC_EVENTS: '"$KAFKA_TOPIC_EVENTS"'"
echo "KAFKA_TOPIC_LOGS: '"$KAFKA_TOPIC_EVENTS"'"
echo "CERT_ELEMENT:  |- "
echo $CERT_ELEMENT
echo "TOKEN: '"$TOKEN"'"

```

> You will have to indent the Certificate!



### Deploying 

```bash
oc apply -n default -f ./tools/97_addons/webhook/create-cp4aiops-event-gateway.yaml

oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}

```


## Mappings 

### Default

```yaml
data:
  ITERATE_ELEMENT: 'events'
  NODE_ELEMENT: 'Node'
  NODEALIAS_ELEMENT: 'NodeAlias'
  ALERT_ELEMENT: 'AlertGroup'
  SUMMARY_ELEMENT: 'Summary'
  TIMESTAMP_ELEMENT: '@timestamp'
  URL_ELEMENT: 'URL'
  SEVERITY_ELEMENT: 'Severity'
  MANAGER_ELEMENT: 'Manager'
```

### elk

```yaml
data:
  ITERATE_ELEMENT: 'events'
  NODE_ELEMENT: 'kubernetes.container_name'
  NODEALIAS_ELEMENT: 'kubernetes.container_name'
  ALERT_ELEMENT: 'kubernetes.namespace_name'
  SUMMARY_ELEMENT: '@rawstring'
  TIMESTAMP_ELEMENT: '@timestamp'
  URL_ELEMENT: 'none'
  SEVERITY_ELEMENT: '5'
  MANAGER_ELEMENT: 'KafkaWebhook'
```




