<center> <h1>CP4WatsonAIOps V3.2</h1> </center>
<center> <h2>Demo Environment Installation - 🐥 EASY INSTALL</h2> </center>

![K8s CNI](./doc/pics/front.png)


<center> ©2022 Niklaus Hirt / IBM </center>


<div style="page-break-after: always;"></div>


### ❗ THIS IS WORK IN PROGRESS
Please drop me a note on Slack or by mail nikh@ch.ibm.com if you find glitches or problems.


# Changes

| Date  | Description  | Files  | 
|---|---|---|
|  17.09.2021 | First Draft |  |
|  20.09.2021 | Turbonomic, Humio and Tooling |  |
|  20.09.2021 | Roles |  |
|  21.09.2021 | Improved robustness and checks |  |
|  22.09.2021 | Corrected some bugs | Thanks Henning Sternkicker |
|  24.09.2021 | Corrected some bugs in the debug script | Thanks Philippe Thomas |
|  06.10.2021 | Resiliency and Usability |  |
|  16.10.2021 | Added EventManager (NOI) Standalone Option | |
|  20.10.2021 | Added AWX Option | Open Source Ansible Tower |
|  21.10.2021 | Added ManageIQ Option | Open Source Cloudforms |
|  26.10.2021 | 10_debug_install.sh script updated | Still work in progress |
|  27.10.2021 | New template structure |  |
|  10.11.2021 | First version for GA 3.2 |  |
|  11.11.2021 | Small tweaks  | Demo and training scripts detect AIMgr and EvtMgr Namespace automatically  |
|  11.11.2021 | Corrected missing wget  | Thanks Nate Malone |
|  19.11.2021 | Humio install  | Based on operator |
|  23.11.2021 | Added Service Mesh/Istio  | Optional |
|  24.11.2021 | Change NOI to EventManager  | including Namespace |
|  20.11.2021 | First stable release  | v1.0 |
|  07.12.2021 | Minor fixes  | thanks Wei Huang |
|  10.12.2021 | Added generic Webhook  | WebHook -> Kafka Events for AI Manager |
|  20.12.2021 | Corrected date format for Linux  | Thanks Petr Styblo|
|  17.01.2022 | Corrected some stuff  | Thanks Mario Schuerewegen|
|  24.01.2022 | Global Installer |  |
|  27.01.2022 | Easy Install |  |
|  31.01.2022 | Automatic Training |  |

<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# Installation
---------------------------------------------------------------

1. [Introduction](#1-introduction)
1. [🐥 Easy Install](#-2-easy-install)
1. [Architecture](#3-architecture)
1. [Configure Applications and Topology](#4-configure-applications-and-topology)
1. [Training](#5-training)
1. [Slack integration](#6-slack-integration)
1. [Some Polishing](#7-some-polishing)
1. [Demo the Solution](#8-demo-the-solution)
1. [Troubleshooting](#9-troubleshooting)
1. [Uninstall CP4WAIOPS](#10-uninstall)
1. [EventManager Configuration](#11-eventmanager-configuration)
1. [Runbook Configuration](#12-runbook-configuration)
1. [Installing Turbonomic](#13-installing-turbonomic)
1. [Installing ELK (optional)](#14-installing-ocp-elk)
1. [Installing Humio (optional)](#15-humio)
1. [Installing ServiceMesh/Istio (optional)](#16-servicemesh)
1. [Installing AWX/AnsibleTower (optional)](#17-awx)
1. [Detailed Prerequisites](#18-detailed-prerequisites)
1. [Detailed CP4WAIOPS Installation](#19-detailed-cp4waiops-installation)
1. [Additional Configuration](#20-additional-configuration)
1. [Service Now integration](#21-service-now-integration)
1. [Manually train the models](#22-manually-train-the-models)

> ❗You can find a PDF version of this guide here: [PDF](./INSTALL_CP4WAIOPS.pdf).

<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 1 Introduction
---------------------------------------------------------------

This repository contains the scrips for installing a Watson AIOps demo environment with an Ansible based installer.

They have been ported over from the shell scripts here [https://github.ibm.com/NIKH/aiops-3.1](https://github.ibm.com/NIKH/aiops-3.1).

As of 3.2 and going forward I will only update the Ansible scripts in this repository.


This is provided `as-is`:

* I'm sure there are errors
* I'm sure it's not complete
* It clearly can be improved


**❗This has been tested for the new CP4WAIOPS 3.2 release on OpenShift 4.7 and 4.8.**

**I have tested on ROKS 4.7 and 4.8 and Fyre 4.6 and the scripts run to completion.**

**❗ Then EventManager/NOI-->AI Manager Gateway is not working yet on ROKS**

So please if you have any feedback contact me 

- on Slack: Niklaus Hirt or
- by Mail: nikh@ch.ibm.com


<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 🐥 2 Easy Install
---------------------------------------------------------------

I have provided a tool to very easily install the different components.

Please follow this chapter and execute all steps marked with 🟢.


## 2.1 Get the code 🟢

Clone the GitHub Repository


```
git clone https://<YOUR GIT TOKEN>@github.ibm.com/NIKH/aiops-install-ansible.git 
```


## 2.2 Prerequisites 

### 2.2.1 OpenShift requirements 🟢

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.8 (4.6 should work also)
- 5x worker nodes Flavor `b3c.16x64` (so 16 CPU / 64 GB) 

You might get away with less if you don't install some components (Event Manager, Humio, Turbonomic,...):

- Typically 3x worker nodes Flavor `b3c.16x64` _**for only AI Manager**_

<div style="page-break-after: always;"></div>

### 2.2.2 Tooling 🟢

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.8 or greater)
- jq
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)



#### 2.2.1 On Mac - Automated (preferred) 🟢

Use Option 🐥`81` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Mac`

#### 2.2.2 On Mac - Automated (preferred) 🟢

Use Option 🐥`82` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Ubuntu`


> If you want the detailed prerequisites you can have a look [here](#18-detailed-prerequisites) 

## 2.3 Get the CP4WAIOPS installation token 🟢

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

<div style="page-break-after: always;"></div>




## 2.4 Install AI Manager 🟢

![K8s CNI](./doc/pics/install-aimanager.png)

### 2.4.1 Launch the Easy Install Tool 🟢

Just run:

```bash
./01_easy-install.sh
```

<div style="page-break-after: always;"></div>

For a vanilla install you will see this:

![K8s CNI](./doc/pics/tool0.png)



<div style="page-break-after: always;"></div>

### 2.4.1 Start AI Manager Installation 🟢

1. Select option 🐥`11` to install a base `AI Manager` instance.
2. Click through the assistant, enter the installation token (if not provided on the command line):

![K8s CNI](./doc/pics/tool1.png)

For complete example log, you can have a look [here](#99-example-installation-log)

### 2.4.2 First Login 🟢

After successful installation, the Easy Installer gives you the URL and the Login Information for your first connections.


You can also run `./tools/20_get_logins.sh` at any moment. This will print out all the relevant passwords and credentials.

Usually it's a good idea to store this in a file for later use:

```bash
./tools/20_get_logins.sh > my_credentials.txt
```

<div style="page-break-after: always;"></div>

## 2.5 Configure AI Manager 🟢

There are some minimal configurations that you have to do to use the demo system and that are covered by the 🅰️ flow:

###  🅰️➡️ 🚀 Start here [Create Kubernetes Observer](#41-create-kubernetes-observer-for-the-demo-applications-)

Just click and follow the 🚀 and execute the steps marked with  🟢.

> ### Minimal Configuration
> 
> Those are the minimal configurations you'll need to demo the system and that are covered by the flow above.
> 
> **Configure Topology**
> 
> 1. Create Kubernetes Observer
> 1. Create REST Observer
> 1. Create Topology (🐥 - Option 51)
> 1. Create AIOps Application
> 
> **Models Training**
> 
> 1. Train the Models (🐥 - Option 55)
> 1. Create Integrations
> 
> **Configure Slack**
> 
> 1. Setup Slack
> 1. Adapt Web Certificates
> 
> **Configure Logins**
> 
> 1. Configure LDAP Logins


<div style="page-break-after: always;"></div>


### 2.5.1 Installing with parameters

You can also provide the following (optional) parameters:

- `t`  Provide registry pull token              <REGISTRY_TOKEN>
- `v`  Verbose mode                             true/false
- `r`  Replace indexes if they already exist    true/false

```bash
./01_easy-install.sh [-t <REGISTRY_TOKEN>] [-v true] [-r true]"
```

In this case you will see the selected options:

![K8s CNI](./doc/pics/tool3.png)

<div style="page-break-after: always;"></div>

## 2.6 Install Event Manager 🟢

![K8s CNI](./doc/pics/install-evtmanager.png)

### 2.6.1 Start Event Manager Installation 🟢

Use Option 🐥`12` in [Easy Install](#-2-easy-install) to install a base `Event Manager` instance

### 2.6.2 Configure Event Manager 🟢

There are some minimal configurations that you have to do to use the demo system and that are covered by the 🅱️ flow below:

###  🅱️➡️ 🚀 Start here [EventManager Configuration](#111-configure-eventmanager-)

<div style="page-break-after: always;"></div>

## 2.7 Installing additional components 🟢

Select the options you want to install.

The ones marked with ✅ have already been detected as being present in the cluster.
![K8s CNI](./doc/pics/tool4.png)


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 3 Architecture
---------------------------------------------------------------


## 3.1 Basic Architecture

The environement (Kubernetes, Applications, ...) create logs that are being fed into a Log Management Tool (Humio in this case).

![](./doc/pics/aiops-demo.png)

1. External Systems generate Alerts and send them into the EventManager (Netcool Operations Insight), which in turn sends them to the AI Manager for Event Grouping.
1. At the same time AI Manager ingests the raw logs coming from the Log Management Tool (Humio) and looks for anomalies in the stream based on the trained model.
1. If it finds an anomaly it forwards it to the Event Grouping as well.
1. Out of this, AI Manager creates a Story that is being enriched with Topology (Localization and Blast Radius) and with Similar Incidents that might help correct the problem.
1. The Story is then sent to Slack.
1. A Runbook is available to correct the problem but not launched automatically.

<div style="page-break-after: always;"></div>

## 3.2 Optimized Demo Architecture

![](./doc/pics/aiops-demo3.png)

For the this specific Demo environment:

* Humio is not needed as I am using pre-canned logs for training and for the anomaly detection (inception)
* The Events are also created from pre-canned content that is injected into AI Manager
* There are also pre-canned ServiceNow Incidents if you don’t want to do the live integration with SNOW
* The Webpages that are reachable from the Events are static and hosted on my GitHub
* The same goes for ServiceNow Incident pages if you don’t integrate with live SNOW

This allows us to:

* Install the whole Demo Environment in a self-contained OCP Cluster
* Trigger the Anomalies reliably
* Get Events from sources that would normally not be available (Instana, Turbonomic, Metrics Manager, ...)
* Show some examples of SNOW integration without a live system


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 4 Configure Applications and Topology
---------------------------------------------------------------



## 4.1 Create Kubernetes Observer for the Demo Applications 🟢

Do this for your applications (RobotShop by default)

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kubernetes`, click on `Add Integration`
* Click `Connect`
* Name it `RobotShop`
* Data Center `demo`
* Click `Next`
* Choose `local` for Connection Type
* Set `Hide pods that have been terminated` to `On`
* Set `Correlate analytics events on the namespace groups created by this job` to `On`
* Set Namespace to `robot-shop`
* Click `Next`
* Click `Done`




## 4.2 Create REST Observer to Load Topologies 🟢

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* On the left click on `Topology`
* On the top right click on `You can also configure, schedule, and manage other observer jobs` 
* Click on  `Add a new Job`
* Select `REST`/ `Configure`
* Choose “bulk_replace”
* Set Unique ID to “listenJob” (important!)
* Set Provider to whatever you like (usually I set it to “listenJob” as well)
* `Save`







<div style="page-break-after: always;"></div>

## 4.3 🐥 Create Topology 🟢

##### Use 🐥 [Easy Install](#-2-easy-install) - Option `51` for creating the Robot-Shop topology or use the manual procedure in chapter 4.5. 


❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.

## 4.4 Create AIOps Application 🟢

#### Robotshop

* In the `AI Manager` go into `Operate` / `Application Management` 
* Click `Define Application`
* Select `robot-shop` namespace
* Click `Next`
* Click `Next`
* Name your Application (RobotShop)
* If you like check `Mark as favorite`
* Click `Define Application`


### 🅰️➡️ 🚀 Next [Train the Models](#51--training-)


<div style="page-break-after: always;"></div>

## 4.5 Manually create Topology (Optional)

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)

### 4.5.1 Create Merge Rules for Kubernetes Observer

Launch the following:

```bash
./51_load_robotshop_topology_aimanager.sh
```

This will create:

- Merge Rules
- Merge Topologies for RobotShop.

❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.



<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 5 Training
---------------------------------------------------------------



## 5.1 🐥 Training 🟢


#### Use 🐥 [Easy Install](#-2-easy-install) - Option `55` to automatically:
- Load the training data
- Create the training definitions
- Launch the trainings

This will be done for:

- Log Anomaly Detection (Logs)
- Temporal Grouping (Events)
- Similar Incidents (Service Now)
- Change Risk (Service Now)

or use the procedure in [Chapter 22](#22-manually-train-the-models) to do this manually. 

<div style="page-break-after: always;"></div>

## 5.2 Create Integrations 🟢

### 5.2.1 Create Kafka Humio Log Training Integration 🟢

* In the `AI Manager` "Hamburger" Menu select `Define`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `HumioInject`
* Click `Next`
* Select `Data Source` / `Logs`
* Select `Mapping Type` / `Humio`
* Paste the following in `Mapping` (the default is **incorrect**!:

	```json
	{
	"codec": "humio",
	"message_field": "@rawstring",
	"log_entity_types": "kubernetes.namespace_name,kubernetes.container_hash,kubernetes.host,kubernetes.container_name,kubernetes.pod_name",
	"instance_id_field": "kubernetes.container_name",
	"rolling_time": 10,
	"timestamp_field": "@timestamp"
	}
	```
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Select `Live data for continuous AI training and anomaly detection`
* Click `Save`


<div style="page-break-after: always;"></div>

### 5.2.2 Create Kafka Netcool Training Integration 🟢

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kafka`, click on `Add Integration`
* Click `Connect`
* Name it `EvetnManager`
* Click `Next`
* Select `Data Source` / `Events`
* Select `Mapping Type` / `NOI`
* Click `Next`
* Toggle `Data Flow` to the `ON` position
* Click `Save`

### 🅰️➡️ 🚀 Next [Setup Slack](#61-initial-slack-setup-)


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 6 Slack integration
---------------------------------------------------------------

## 6.1 Initial Slack Setup 🟢

For the system to work you need to setup your own secure gateway and slack workspace. It is suggested that you do this within the public slack so that you can invite the customer to the experience as well. It also makes it easier for is to release this image to Business partners

You will need to create your own workspace to connect to your instance of CP4WAOps.

Here are the steps to follow:

1. [Create Slack Workspace](./doc/slack/1_slack_workspace.md)
1. [Create Slack App](./doc/slack/2_slack_app_create.md)
1. [Create Slack Channels](./doc/slack/3_slack_channel.md)
1. [Create Slack Integration](./doc/slack/4_slack_integrate.md)
1. [Get the Integration URL - Public Cloud - ROKS](./doc/slack/5_slack_url_public.md) OR 
1. [Get the Integration URL - Private Cloud - Fyre/TEC](./doc/slack/5_slack_url_private.md)
1. [Create Slack App Communications](./doc/slack/6_slack_app_integration.md)
1. [Slack Reset](./doc/slack/7_slack_reset.md)


<div style="page-break-after: always;"></div>

## 6.2 Create valid CP4WAIOPS Certificate 🟢


In order for Slack integration to work, there must be a signed certicate on the NGNIX pods. The default certificate is self-signed and Slack will not accept that. The method for updating the certificate has changed between AIOps v2.1 and V3.1.1. The NGNIX pods in V3.1.1 mount the certificate through a secret called `external-tls-secret` and that takes precedent over the certificates staged under `/user-home/_global_/customer-certs/`.

For customer deployments, it is required for the customer to provide their own signed certificates. An easy workaround for this is to use the Openshift certificate when deploying on ROKS. **Caveat**: The CA signed certificate used by Openshift is automatically cycled by ROKS (I think every 90 days), so you will need to repeat the below once the existing certificate is expired and possibly reconfigure Slack.



This method replaces the existing secret/certificate with the one that OpenShift ingress uses, not altering the NGINX deployment. An important note, these instructions are for configuring the certificate post-install. Best practice is to follow the installation instructions for configuring certificates during that time.

<div style="page-break-after: always;"></div>

### 6.2.1 Patch AutomationUIConfig

The custom resource `AutomationUIConfig/iaf-system` controls the certificates and the NGINX pods that use those certificates. Any direct update to the certificates or pods will eventually get overwritten, unless you first reconfigure `iaf-system`. It's a bit tricky post-install as you will have to recreate the `iaf-system` resource quickly after deleting it, or else the installation operator will recreate it. For this reason it's important to run all the commands one after the other. **Ensure that you are in the project for AIOps**, then paste all the code on your command line to replace the `iaf-system` resource.

```bash
NAMESPACE=$(oc project -q)
IAF_STORAGE=$(oc get AutomationUIConfig -n $NAMESPACE -o jsonpath='{ .items[*].spec.storage.class }')
oc get -n $NAMESPACE AutomationUIConfig iaf-system -oyaml > iaf-system-backup.yaml
oc delete -n $NAMESPACE AutomationUIConfig iaf-system
cat <<EOF | oc apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: iaf-system
  namespace: $NAMESPACE
spec:
  description: AutomationUIConfig for cp4waiops
  license:
    accept: true
  version: v1.0
  storage:
    class: $IAF_STORAGE
  tls:
    caSecret:
      key: ca.crt
      secretName: external-tls-secret
    certificateSecret:
      secretName: external-tls-secret
EOF
```

<div style="page-break-after: always;"></div>

### 6.2.2 NGNIX Certificate

Again, **ensure that you are in the project for AIOps** and run the following to replace the existing secret with a secret containing the OpenShift ingress certificate.

```bash
WAIOPS_NAMESPACE =$(oc project -q)
# collect certificate from OpenShift ingress
ingress_pod=$(oc get secrets -n openshift-ingress | grep tls | grep -v router-metrics-certs-default | awk '{print $1}')
oc get secret -n openshift-ingress -o 'go-template={{index .data "tls.crt"}}' ${ingress_pod} | base64 -d > cert.crt
oc get secret -n openshift-ingress -o 'go-template={{index .data "tls.key"}}' ${ingress_pod} | base64 -d > cert.key
oc get secret -n $WAIOPS_NAMESPACE iaf-system-automationui-aui-zen-ca -o 'go-template={{index .data "ca.crt"}}'| base64 -d > ca.crt
# backup existing secret
oc get secret -n $WAIOPS_NAMESPACE external-tls-secret -o yaml > external-tls-secret$(date +%Y-%m-%dT%H:%M:%S).yaml
# delete existing secret
oc delete secret -n $WAIOPS_NAMESPACE external-tls-secret
# create new secret
oc create secret generic -n $WAIOPS_NAMESPACE external-tls-secret --from-file=ca.crt=ca.crt --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | oc apply -f -
#oc create secret generic -n $WAIOPS_NAMESPACE external-tls-secret --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | oc apply -f -
# scale down nginx
REPLICAS=2
oc scale Deployment/ibm-nginx --replicas=0
# scale up nginx
sleep 3
oc scale Deployment/ibm-nginx --replicas=${REPLICAS}
rm external-tls-secret
```


Wait for the nginx pods to come back up

```bash
oc get pods -l component=ibm-nginx
```

When the integration is running, remove the backup file

```bash
rm ./iaf-system-backup.yaml
```

And then restart the Slack integration Pod

```bash
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep slack|awk '{print$1}') -n $WAIOPS_NAMESPACE --grace-period 0 --force
```

The last few lines scales down the NGINX pods and scales them back up. It takes about 3 minutes for the pods to fully come back up.

Once those pods have come back up, you can verify the certificate is secure by logging in to AIOps. Note that the login page is not part of AIOps, but rather part of Foundational Services. So you will have to login first and then check that the certificate is valid once logged in. If you want to update the certicate for Foundational Services you can find instructions [here](https://www.ibm.com/docs/en/cpfs?topic=operator-replacing-foundational-services-endpoint-certificates).

### 🅰️➡️ 🚀 Next [Configure LDAP Logins](#71-add-ldap-logins-to-cp4waiops-)

## 6.3 Change the Slack Slash Welcome Message (optional)

If you want to change the welcome message

```bash
oc set env deployment/$(oc get deploy -l app.kubernetes.io/component=chatops-slack-integrator -o jsonpath='{.items[*].metadata.name }') SLACK_WELCOME_COMMAND_NAME=/aiops-help
```


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 7 Some Polishing
---------------------------------------------------------------

## 7.1 Add LDAP Logins to CP4WAIOPS 🟢


* Go to `AI Manager` Dashboard
* Click on the top left "Hamburger" menu
* Select `User Management`
* Select `User Groups` Tab
* Click `New User Group`
* Enter demo (or whatever you like)
* Click Next
* Select `LDAP Groups`
* Search for `demo`
* Select `cn=demo,ou=Groups,dc=ibm,dc=com`
* Click Next
* Select Roles (I use Administrator for the demo environment)
* Click Next
* Click Create

### 🅰️➡️ 🚀 Back to [Easy Install](#-2-easy-install)


---


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 8 Demo the Solution
---------------------------------------------------------------



## 7.1 Simulate incident - Demo UI

> ❗**In order to use the DEMO UI, you have to have followed through all the steps in [AI Manager Configuration](#25-configure-ai-manager). Notably Configuring Topology, Integrations and having run the Models Training.**

### 7.1.1 Install Demo UI

#### Use 🐥 [Easy Install](#-2-easy-install) - Option `17` to automatically install a Demo UI instance.

## 7.1.2 Simulate incident - Demo UI

1. Run `./tools/20_get_logins.sh` to get the URL and Login Token.
1. Open the URL and enter the Token.
	![](./doc/pics/demoui1.png)
1. Click on Configuration
1. Verify that you have `Kafka Topics` shown for Events and Logs
	![](./doc/pics/demoui2.png)
1. Click `Back`
1. Now you can use the buttons to simulate:

	* Only Events
	* Only Log Anomalies
	* or Both
	![](./doc/pics/demoui1.png)

1. The UI will confirm that the incident creation has been launched
	![](./doc/pics/demoui3.png)

## 7.2 Simulate incident - Command Line

**Make sure you are logged-in to the Kubernetes Cluster first** 

In the terminal type 

```bash
./tools/01_demo/incident_robotshop.sh
```

This will delete all existing Alerts and inject pre-canned event and logs to create a story.

ℹ️  Give it a minute or two for all events and anomalies to arrive in Slack.






<div style="page-break-after: always;"></div>

---------------------------------------------------------------

# 9 TROUBLESHOOTING
---------------------------------------------------------------

## 9.1 Check with script

❗ There is a new script that can help you automate some common problems in your CP4WAIOPS installation.

Just run:

```
./tools/10_debug_install.sh
```

and select `Option 1`


## 9.2 Pods in Crashloop

If the evtmanager-topology-merge and/or evtmanager-ibm-hdm-analytics-dev-inferenceservice are crashlooping, apply the following patches. I have only seen this happen on ROKS.

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch deployment evtmanager-topology-merge -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/pazch/topology-merge-patch.yaml


oc patch deployment evtmanager-ibm-hdm-analytics-dev-inferenceservice -n $WAIOPS_NAMESPACE --patch-file ./yaml/waiops/patch/evtmanager-inferenceservice-patch.yaml
```


<div style="page-break-after: always;"></div>

## 9.3 Pods with Pull Error

If the ir-analytics or cassandra job pods are having pull errors, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-topology-service-account -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-worker -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-pipeline-composer -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-spark-master -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-probablecause -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-analytics-classifier -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
kubectl patch -n $WAIOPS_NAMESPACE serviceaccount aiops-ir-lifecycle-eventprocessor-ep -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key"}]}'
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep ImagePull|awk '{print$1}') -n $WAIOPS_NAMESPACE


```


## 9.4 Camel-K Handlers Error

If the scm-handler or snow-handler pods are not coming up, apply the following patches. 

```bash
export WAIOPS_NAMESPACE=cp4waiops

oc patch vaultaccess/ibm-vault-access -p '{"spec":{"token_period":"760h"}}' --type=merge -n $WAIOPS_NAMESPACE
oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep 0/| grep -v "Completed"|awk '{print$1}') -n $WAIOPS_NAMESPACE

```




## 9.5 Slack integration not working

See [here](#ngnix-certificate-for-v31---if-the-integration-is-not-working)

<div style="page-break-after: always;"></div>



## 9.6 Check if data is flowing

### 9.6.1 Check Log injection

To check if logs are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 4

You should see data coming in.

### 9.6.2 Check Events injection

To check if events are being injected through the demo script:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 3

You should see data coming in.

### 9.6.3 Check Stories being generated

To check if stories are being generated:

1. Launch 

	```bash
	./tools/22_monitor_kafka.sh
	```
2. Select option 2

You should see data being generated.

<div style="page-break-after: always;"></div>

## 9.7 Docker Pull secret

####  ❗⚠️ Make a copy of the secret before modifying 
####  ❗⚠️ On ROKS (any version) and before 4.7 you have to restart the worker nodes after the modification  

We learnt this the hard way...

```bash
oc get secret -n openshift-config pull-secret -oyaml > pull-secret_backup.yaml
```

or more elegant

```bash
oc get Secret -n openshift-config pull-secret -ojson | jq 'del(.metadata.annotations, .metadata.creationTimestamp, .metadata.generation, .metadata.managedFields, .metadata.resourceVersion , .metadata.selfLink , .metadata.uid, .status)' > pull-secret_backup.json
```

In order to avoid errors with Docker Registry pull rate limits, you should add your Docker credentials to the Cluster.
This can occur especially with Rook/Ceph installation.

* Go to Secrets in Namespace `openshift-config`
* Open the `pull-secret`Secret
* Select `Actions`/`Edit Secret` 
* Scroll down and click `Add Credentials`
* Enter your Docker credentials

	![](./doc/pics/dockerpull.png)

* Click Save

If you already have Pods in ImagePullBackoff state then just delete them. They will recreate and should pull the image correctly.




<div style="page-break-after: always;"></div>

## 9.8 Monitor ElasticSearch Indexes

At any moment you can run `./tools/28_access_elastic.sh` in a separate terminal window.

This allows you to access ElasticSearch and gives you:

* ES User
* ES Password

	![](./doc/pics/es0.png)
	

### 9.8.1 Monitor ElasticSearch Indexes from Firefox

I use the [Elasticvue](https://addons.mozilla.org/en-US/firefox/addon/elasticvue/) Firefox plugin.

Follow these steps to connects from Elasticvue:

- Select `Add Cluster` 
	![](./doc/pics/es1.png)

<div style="page-break-after: always;"></div>

- Put in the credentials and make sure you put `https` and not `http` in the URL
	![](./doc/pics/es2.png)
- Click `Test Connection` - you will get an error
- Click on the `https://localhost:9200` URL
	![](./doc/pics/es3.png)
	
<div style="page-break-after: always;"></div>

- This will open a new Tab, select `Accept Risk and Continue` 
	![](./doc/pics/es4.png)
- Cancel the login screen and go back to the previous tab
- Click `Connect` 
- You should now be connected to your AI Manager ElasticSearch instance 
	![](./doc/pics/es5.png)

<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 10 Uninstall
---------------------------------------------------------------

❗ The scritps are coming from here [https://github.com/IBM/cp4waiops-samples.git](https://github.com/IBM/cp4waiops-samples.git)

If you run into problems check back if there have been some updates.


I have tested those on 3.1.1 as well and it seemed to work (was able to do a complete reinstall afterwards).

Just run:

```
./tools/99_uninstall/3.2/uninstall-cp4waiops.props
```





<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 11 EventManager Configuration
---------------------------------------------------------------

## 11.1 Configure EventManager 🟢

❗ You only have to do this if you have installed EventManager/NOI (As described in Easy Install - Chapter 6). For basic demoing with AI MAnager this is not needed.




### 11.1.1 Create Kubernetes Observer for the Demo Applications 🟢

This is basically the same as for AI Manager as we need two separate instances of the Topology Manager. 


* In the `Event Manager` "Hamburger" Menu select `Administration`/`Topology Management`
* Under `Observer jobs` click `Configure`
* Click `Add new job`
* Under `Kubernetes`, click on `Configure`
* Choose `local` for `Connection Type`
* Set `Unique ID` to `robot-shop`
* Set `data_center` to `robot-shop`
* Under `Additional Parameters`
* Set `Terminated pods` to `true`
* Set `Correlate` to `true`
* Set Namespace to `robot-shop`
* Under `Job Schedule`
* Set `Time Interval` to 5 Minutes
* Click `Save`




### 11.1.2 Create REST Observer to Load Topologies 🟢

* In the `Event Manager` "Hamburger" Menu select `Administration`/`Topology Management`
* Under `Observer jobs` click `Configure`
* Click `Add new job`
* Under `REST`, click on `Configure`
* Choose `bulk_replace` for `Job Type`
* Set `Unique ID` to `listenJob` (important!)
* Set `Provider` to `listenJob` 
* Click `Save`







<div style="page-break-after: always;"></div>

### 11.1.3 🐥 Create Topology 🟢

##### Use 🐥 [Easy Install](#-2-easy-install) - Option `52` for creating the Robot-Shop topology or use the manual procedure in chapter 4.5. 


❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.



### 11.1.4 EventManager Webhook 🟢

Create Webhooks in EventManager for Event injection and incident simulation for the Demo.

The demo scripts (in the `demo` folder) give you the possibility to simulate an outage without relying on the integrations with other systems.

At this time it simulates:

- Git push event
- Log Events (Humio)
- Security Events (Falco)
- Instana Events
- Metric Manager Events (Predictive)
- Turbonomic Events
- CP4MCM Synthetic Selenium Test Events



<div style="page-break-after: always;"></div>


You have to define the following Webhook in EventManager (NOI): 

* `Administration` / `Integration with other Systems`
* `Incoming` / `New Integration`
* `Webhook`
* Name it `Demo Generic`
* Jot down the WebHook URL and copy it to the `NETCOOL_WEBHOOK_GENERIC` in the `./tools/01_demo/incident_robotshop-noi.sh`file
* Click on `Optional event attributes`
* Scroll down and click on the + sign for `URL`
* Click `Confirm Selections`


Use this json:

```json
{
  "timestamp": "1619706828000",
  "severity": "Critical",
  "summary": "Test Event",
  "nodename": "productpage-v1",
  "alertgroup": "robotshop",
  "url": "https://pirsoscom.github.io/grafana-robotshop.html"
}
```

Fill out the following fields and save:

* Severity: `severity`
* Summary: `summary`
* Resource name: `nodename`
* Event type: `alertgroup`
* Url: `url`
* Description: `"URL"`

Optionnally you can also add `Expiry Time` from `Optional event attributes` and set it to a convenient number of seconds (just make sure that you have time to run the demo before they expire.

<div style="page-break-after: always;"></div>

### 11.1.5 Create custom Filter and View in EventManager 🟢






#### 11.1.5.1 Filter 🟢


* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Administration`
* Click `Filters`
* Select `Global Filters` from the DropDown menu
* Select `Default`
* Click `Copy Filter` (the two papers on the top left) 
* Set to `global`
* Click `Ok`
* Name: AIOPS
* Logic: **Any** ❗ (the right hand option)
* Filter:
	* AlertGroup = 'CEACorrelationKeyParent'
	* AlertGroup = 'robot-shop'

![](./doc/pics/noi10.png)


#### 11.1.5.2 View 🟢
* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Administration`
* Click `Views`
* Select `System Views` from the DropDown menu
* Select `Example_IBM_CloudAnalytics`
* Click `Copy View` (the two papers on the top left) 
* Set to `global`
* Click `Ok`
* Name: AIOPS
* Configure to your likings.


### 11.1.6 Create grouping Policy 🟢

* In the `Event Manager` "Hamburger" Menu select `Netcool WebGui`
* Click `Insights`
* Click `Scope Based Grouping`
* Click `Create Policy`
* `Action` select fielt `Alert Group`
* Toggle `Enabled` to `On`
* Save

<div style="page-break-after: always;"></div>

### 11.1.7 Create EventManager/NOI Menu item - Open URL 🟢

in the Netcool WebGUI

* Go to `Administration` / `Tool Configuration`
* Click on `LaunchRunbook`
* Copy it (the middle button with the two sheets)
* Name it `Launch URL`
* Replace the Script Command with the following code

	```javascript
	var urlId = '{$selected_rows.URL}';
	
	if (urlId == '') {
	    alert('This event is not linked to an URL');
	} else {
	    var wnd = window.open(urlId, '_blank');
	}
	```
* Save

Then 

* Go to `Administration` / `Menu Configuration`
* Select `alerts`
* Click on `Modify`
* Move Launch URL to the right column
* Save

### 🅱️➡️ 🚀 Next [Configure Ansible Tower Runbooks](#121-configure-runbooks-with-awx-)

or if you don't use AWX 

#### 🅱️➡️ 🚀 Next [Configure Runbooks with bastion host](#122-configure-runbooks-with-bastion-server)

<div style="page-break-after: always;"></div>

### 11.1.8 Create Templates for Topology Grouping (optional)

This gives you probale cause and is not strictly needed if you don't show EventManager!

* In the EventManager "Hamburger" Menu select `Operate`/`Topology Viewer`
* Then, in the top right corner, click on the icon with the three squares (just right of the cog)
* Select `Create a new Template`
* Select `Dynamic Template`

Create a template for RobotShop:

* Search for `web-deployment` (deployment)
* Create Topology 3 Levels
* Name the template (robotshop)
* Select `Namespace` in `Group type`
* Enter `robotshop_` for `Name prefix`
* Select `Application` 
* Add tag `namespace:robot-shop`
* Save

### 11.1.9 Manually create Topology (optional)

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)



### 11.1.9.1 Create Merge Rules for Kubernetes Observer

Launch the following:

```bash
./52_load_robotshop_topology_eventmanager.sh
```

This will create:

- Merge Rules
- Merge Topologies for RobotShop.

❗ Please manually re-run the Kubernetes Observer to make sure that the merge has been done.


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 12 Runbook Configuration
---------------------------------------------------------------

## 12.1 Configure Runbooks with AWX 🟢

This is the preferred method.

Use Option 🐥`23` in [Easy Install](#-2-easy-install) to install an `AWX ` instance if you haven't done so yet.


### 12.1.1 Configure AWX 🟢

There is some demo content available to RobotShop.

1. Log in to AWX
2. Add a new Project
	1. Name it `DemoCP4WAIOPS`
	1. Source Control Credential Type to `Git`
	1. Set source control URL to `https://github.com/niklaushirt/ansible-demo`
	2. Save
	
1. Add new Job Template
	1. Name it `Mitigate Robotshop Ratings Outage`
	2. Select Inventory `Demo Inventory`
	3. Select Project `DemoCP4WAIOPS`
	4. Select Playbook `cp4waiops/robotshop-restart/start-ratings.yaml`
	5. Select` Prompt on launch` for `Variables`  ❗
	2. Save



### 12.1.2 Configure AWX Integration 🟢

In EventManager:

1. Select `Administration` / `Integration with other Systems`
1. Select `Automation type` tab
1. For `Ansible Tower` click  `Configure`
2. Enter the URL and credentials for your AWX instance (you can use the defautl `admin` user)
3. Click Save

<div style="page-break-after: always;"></div>

### 12.1.3 Configure Runbook 🟢

In EventManager:

1. Select `Automations` / `Runbooks`
1. Select `Library` tab
1. Click  `New Runbook`
1. Name it `Mitigate Robotshop Ratings Outage`
1. Click `Add automated Step`
2. Select the `Mitigate Robotshop Ratings Outage` Job

	![](./doc/pics/rb1.png)

3. Click `Select this automation`
4. Select `New Runbook Parameter`

	![](./doc/pics/rb2.png)

5. Name it `ClusterCredentials`
6. Input the login credentials in JSON Format (get the URL and token from the 20\_get\_logins.sh script)

	![](./doc/pics/rb5.png)
	
	```json
	{     
		"my_k8s_apiurl": "https://c117-e.xyz.containers.cloud.ibm.com:12345",
		"my_k8s_apikey": "PASTE YOUR API KEY"
	}
	```
	
	![](./doc/pics/rb3.png)

7. Click Save

	![](./doc/pics/rb4.png)
	
7. Click Publish


	
	
Now you can test the Runbook by clicking on `Run`.

<div style="page-break-after: always;"></div>

### 12.1.4 Add Runbook Triggers 🟢

1. Select `Automations` / `Runbooks`
1. Select `Triggers` tab
1. Click  `New Trigger `
1. Name it `Mitigate Robotshop Ratings Outage`
1. Add conditions:
   * Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-instana or mysql-predictive
1. Click `Run Test`
2. You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
3. Select `Mitigate RobotShop Problem`
4. Click `Select This Runbook`
5. Toggle `Execution` / `Automatic` to `off`
6. Under `Parameters for this runbook` select `Manual` and input the login credentials in JSON Format (get the URL and token from the 20\_get\_logins.sh script)

	```json
	{     
		"my_k8s_apiurl": "https://c117-e.xyz.containers.cloud.ibm.com:12345",
		"my_k8s_apikey": "PASTE YOUR API KEY"
	}
	```
6. Click `Save`



### 🅱️➡️ 🚀 Back to [Easy Install](#-2-easy-install)

<div style="page-break-after: always;"></div>


## 12.2 Configure Runbooks with bastion server

> ### ❗Old method

### 12.2.1 Create Bastion Server

A simple Pod with the needed tools (oc, kubectl) being used as a bastion host for Runbook Automation should already have been created by the install script. 



### 12.2.2 Create the EventManager/NOI Integration

#### 12.2.2.1 In EventManager/NOI

* Go to  `Administration` / `Integration with other Systems` / `Automation Type` / `Script`
* Copy the SSH KEY


#### 12.2.2.2 Adapt SSL Certificate in Bastion Host Deployment. 

* Select the `bastion-host` Deployment in Namespace `default`
* Adapt Environment Variable SSH_KEY with the key you have copied above.



### 12.2.3 Create Automation


#### 12.2.3.1 Connect to Cluster
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc login --token=$token --server=$ocp_url --insecure-skip-tls-verify
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root
$token	 : Token from your login (from ./tools/20_get_logins.sh)	
$ocp_url : URL from your login (from ./tools/20_get_logins.sh, something like https://c102-e.eu-de.containers.cloud.ibm.com:32236)		
```

<div style="page-break-after: always;"></div>

#### 12.2.3.2 RobotShop Mitigate MySql
`Automation` / `Runbooks` / `Automations` / `New Automation`


```bash
oc scale deployment --replicas=1 -n robot-shop ratings
oc delete pod -n robot-shop $(oc get po -n robot-shop|grep ratings |awk '{print$1}') --force --grace-period=0
```

Use these default values

```yaml
target: bastion-host-service.default.svc
user:   root		
```


### 12.2.4 Create Runbooks


* `Library` / `New Runbook`
* Name it `Mitigate RobotShop Problem`
* `Add Automated Step`
* Add `Connect to Cluster`
* Select `Use default value` for all parameters
* Then `RobotShop Mitigate Ratings`
* Select `Use default value` for all parameters
* Click `Publish`




### 12.2.5 Add Runbook Triggers

* `Triggers` / `New Trigger`
* Name and Description: `Mitigate RobotShop Problem`
* Conditions
	* Name: RobotShop
	* Attribute: Node
	* Operator: Equals
	* Value: mysql-instana or mysql-predictive
* Click `Run Test`
* You should get an Event `[Instana] Robotshop available replicas is less than desired replicas - Check conditions and error events - ratings`
* Select `Mitigate RobotShop Problem`
* Click `Select This Runbook`
* Toggle `Execution` / `Automatic` to `off`
* Click `Save`



<div style="page-break-after: always;"></div>

-----------------------------------------------------------------------------------
# 13 Installing Turbonomic
---------------------------------------------------------------

## 13.1 Installing Turbonomic

Use Option 🐥`21` in [Easy Install](#-2-easy-install) to install a `Turbonomic` instance

## 13.2 Manually Installing Turbonomic

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.



You can install Turbonomic into the same cluster as CP4WAIOPS.

**❗ You need a license in order to use Turbonomic.**

1. Launch

	```bash
	ansible-playbook ./ansible/20_install-turbonomic.yaml
	```
2. Wait for the pods to come up
3. Open Turbonomic
4. Enter the license
5. Add the default target (local Kubernetes cluster is already instrumented with `kubeturbo`)

It can take several hours for the Supply Chain to populate, so be patient.

## 13.3 Installing kubeturbo

In order to get other Kubernetes clusters to show up in Turbonomic, you have to install `kubeturbo` (your main cluster is already registered).

1. Adapt `./ansible/templates/kubeturbo/my_kubeturbo_instance_cr.yaml` with the Turbonomic URL and the login
2. Launch

	```bash
	ansible-playbook ./ansible/20_1_aiops-addons-kubeturbo.yaml
	```
<div style="page-break-after: always;"></div>

## 13.4 Turbo to WAIOPS Gateway

**❗This is not an officialy supported tool by any means and is still under heavy development!**

In order to push Turbonomic Actions into EventManager you can use my tool.
This tool needs existing `Business Applications`, you can either integrate with Instana (or other APMs) or create one under Settings/Topology.

1. Adapt the `./ansible/templates/turbo-gateway/create-turbo-gateway.yaml` file 

	| Variable | Default Value | Description |
	| -------- | ------------- | ----------- |
	|POLLING_INTERVAL| '300' | Poll every X seconds |
	|EVTMGR_SUMMARY_PREFIX| '[Turbonomic] ' | Prefix in the event summary |
	|EVTMGR_WEBHOOK_URL| netcool-evtmanager.apps.clustername.domain | EventManager hostname |
	|EVTMGR_WEBHOOK_PATH| /norml/xxxx | Webhook URL from EventManager (does not inclue the hostname, only `/norml/xxxx`) |
	|TURBO_API_URL| api-turbonomic.apps.clustername.domain | Turbonomic API URL |
	|TURBO_BA_NAME| 'RobotShop:robot-shop'| Turbonomic application name in the format APPNAME:ALERTGROUP. This links an EventManager alertgroup with an application |
	|ACTION_STATES| 'SUCCEEDED,FAILED,READY,IN_PROGRESS' | The list of ACTION_STATES to filter on |
	|ACTION_TYPES| 'MOVE,RESIZE_FOR_PERFORMANCE,RESIZE_FOR_EFFICIENCY,RESIZE' | The list of ACTION_TYPES to filter on |
	|DEBUG_ENABLED| 'false' | Enable additional log output |
	|ENTITY_TYPES| 'VirtualMachine,Application,PhysicalMachine,ContainerSpec,WorkloadController,Container' | The list of ENTITY_TYPES to filter on |
	|ACTION_START_TIME| '-30m'| Period of time in which actions are retrieved. E.g. -5m, -30m, -1h, -1d, -3d, -7d | 

2. Create Turbonomic Credentials Secret

	You can either:
	
	- create the secret from the command line (which will throw a warning for the already existing Secret when installing)
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=<youruser> --from-literal=TURBO_PWD=<yourpw>
		```

<div style="page-break-after: always;"></div>

	- replace the secret in the yaml file with
	
		```
		oc -n default create secret generic turbo-creds --from-literal=TURBO_USER=apiuser --from-literal=TURBO_PWD=turboadmin -o yaml --dry-run=client
		```


​	
3. Create Generic Webhook in EventManager/NOI with:

	```json
	{
	"timestamp": "1619706828000",
	"severity": "Critical",
	"summary": "Test Event",
	"nodename": "productpage-v1",
	"alertgroup": "robotshop",
	"url": "https://myturbo/something.html"
	}
	```
4. Launch 

	```shell
	ansible-playbook ./ansible/20_3_aiops-addons-turbonomic-gateway.yaml
	```

<div style="page-break-after: always;"></div>

## 13.5 Generate Metrics

**❗This is not an officialy supported tool by any means and is still under heavy development!**

If you have manually created a `Business Applications` you won't get any ResponseTime and Transactions metrics.
With this tool you can you can add randomized ResponseTime and Transactions metrics to the `Business Application` through the `Data Integration Framework (DIF)`.

> Note: The metrics pod can also serve metrics for other `Entity` types (businessApplication, businessTransaction, service, databaseServer, application)
> 
> Note: There is also a Route being created by the installer, so that you can test the URLs.
> 

1. Launch

	```shell
	ansible-playbook ./ansible/20_2_aiops-addons-turbonomic-metrics.yaml
	```

1. Wait for the Pod to become available
1. Add the DIF Target
	2. Go to `Settings/Target Configurations`
	2. Click `New Target`
	2. Select `Custom/DataIngestionFramework`
	2. Put in the URL for the metrics (see below) and a name
	2. Click `Add`
	3. Make sure that Target is green and reads `Validated`

It takes some time for the metrics to start showing up. Polling is every 10 minutes 

### 13.5.1 Test URL

You can use the following URL to test if everything is working:

`http://turbo-dif-service.default:3000/helloworld`

This will create a standalone `Business Application` called `Hello World` without any other `Entities` attached to it. 
But with metrics being ingested.

<div style="page-break-after: always;"></div>

### 13.5.2 Construct the URL

The URL has the format of:

```yaml
http://turbo-dif-service.default:3000/<TYPE>/<NAME>/<UUID>
```

where:

- TYPE: Type of the `Entity` (businessApplication/businessTransaction/service/databaseServer/application)
- NAME: The name of the `Entity`
- UUID: The UUID that you can find under `Entity Information / Show All / Vendor ID`

So an example might be:
`http://turbo-dif-service.default:3000/service/Service-robot-shop%2Fcatalogue/b2d6fd52-c895-469e-bb98-2a791faefce7`
`http://turbo-dif-service.default:3000/businessApplication/RobotShop/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopCatalog/285333292080720`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShoßpPayment/285333133684640`
`http://turbo-dif-service.default:3000/businessTransaction/RobotShopUser/285333133684640`


<div style="page-break-after: always;"></div>

-----------------------------------------------------------------------------------
# 14 Installing OCP ELK
---------------------------------------------------------------

## 14.1 Installing OCP ELK

Use Option 🐥`25` in [Easy Install](#-2-easy-install) to install a `ELK` instance

## 14.2 Manually installing OCP ELK

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

You can easily install ELK into the same cluster as CP4WAIOPS.


1. Launch

	```bash
	ansible-playbook ./ansible/22_install-elk-ocp.yaml
	```
2. Wait for the pods to come up
3. Open Kibana


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 15 HUMIO 
---------------------------------------------------------------

## 15.1 Installing HUMIO

Use Option 🐥`22` in [Easy Install](#-2-easy-install) to install a `HUMIO ` instance

## 15.2 Live Humio integration with AI Manager

### 15.2.1 Humio URL

- Get the Humio Base URL from your browser
- Add at the end `/api/v1/repositories/aiops/query`


### 15.2.2 Accounts Token

Get it from Humio --> `Owl` in the top right corner / `Your Account` / `API Token
`

<div style="page-break-after: always;"></div>

### 15.2.3 Create Humio Log Integration

* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Under `Humio`, click on `Add Connection`
* Click `Connect`
* Name it `Humio`
* Paste the URL from above (`Humio service URL`)
* Paste the Token from above (`API key`)
* In `Filters (optional)` put the following:

	```yaml
	"kubernetes.namespace_name" = /robot-shop/
	| "kubernetes.container_name" = web or ratings or catalogue
	```
* Click `Next`
* Put in the following mapping:

	```yaml
	{
	  "codec": "humio",
	  "message_field": "@rawstring",
	  "log_entity_types": "clusterName, kubernetes.container_image_id, kubernetes.host, kubernetes.container_name, kubernetes.pod_name",
	  "instance_id_field": "kubernetes.container_name",
	  "rolling_time": 10,
	  "timestamp_field": "@timestamp"
	}
	```

* Click `Test Connection`
* Switch `Data Flow` to the `ON` position ❗
* Select the option for your use case:
	* `Live data for continuous AI training and anomaly detection` if you want to enable log anomaly detection
	* `Live data for initial AI training` if you want to start ingesting live data for later training
	* `Historical data for initial AI training` if you want to ingest historical data to start training rapidly
* Click `Done`

<div style="page-break-after: always;"></div>

## 15.3 Manually installing HUMIO

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

> ❗This demo supports pre-canned events and logs, so you don't need to install and configure Humio unless you want to do a live integration (only partially covered in this document).

### 15.3.1 Create Licence Secret

Before starting the installation you have to create the Secret with the licence information.

```bash
oc create ns humio-logging
oc create secret generic humio-license -n humio-logging --from-literal=data=eyJhbGciOiJFUzxxxxaWmdRTrr_ksdfaa
```

### 15.3.2 Install Humio and Fluentbit

Just launch the following and this should automatically install:

* Kafka
* Zookeeper
* Humio Core
* Humio Repository
* Humio Ingest Token
* Fluentbit


```bash
ansible-playbook ./ansible/21_install-humio.yaml
```

<div style="page-break-after: always;"></div>

## 15.4 Live Humio integration with Event Manager


### 15.4.1 Create Humio Events Integration

Events integration is done via EventManager/NOI.

For the time being this only takes the first alert being pushed over (no way to handle arrays).
The native Humio integration seems to have a bug that gives "mergeAdvanced is not a function".


#### 15.4.1.1 On the EventManager/NOI side

Create a Webhook integration:

| Field  | Value  | 
|---|---|
| Severity|"Critical"|
| Summary|  alert.name|
| Resource name | events[0]."kubernetes.container_name"|
| Event type |   events[0]."kubernetes.namespace_name"|



With this sample payload:

```json
{
  "repository": "aiops",
  "timestamp": "2021-11-19T15:50:04.958Z",
  "alert": {
    "name": "test1",
    "description": "",
    "query": {
      "queryString": "\"kubernetes.container_name\" = ratings\n| @rawstring = /error/i ",
      "end": "now",
      "start": "2s"
    },
    "notifierID": "Rq4a9KUbomSIBvEcdC7kzzmdBtPI3yPb",
    "id": "rCA2w5zaIE6Xr3RKlFfhAxqqbGqGxGLC"
  },
  "warnings": "",
  "events": [
    {
      "kubernetes.annotations.openshift_io/scc": "anyuid",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/network-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.annotations.cni_projectcalico_org/podIPs": "172.30.30.153/32",
      "@timestamp.nanos": "0",
      "kubernetes.annotations.k8s_v1_cni_cncf_io/networks-status": "[{\n    \"name\": \"k8s-pod-network\",\n    \"ips\": [\n        \"172.30.30.153\"\n    ],\n    \"default\": true,\n    \"dns\": {}\n}]",
      "kubernetes.pod_name": "ratings-5d9dff56bd-864kq",
      "kubernetes.labels.service": "ratings",
      "kubernetes.annotations.cni_projectcalico_org/podIP": "172.30.30.153/32",
      "kubernetes.host": "10.112.243.226",
      "kubernetes.container_name": "ratings",
      "kubernetes.labels.pod-template-hash": "5d9dff56bd",
      "kubernetes.docker_id": "87a98617a14684c02d9d52a6245af377f8b1a246d196f232cad494a7a2d125b7",
      "@ingesttimestamp": "1637337004272",
      "kubernetes.container_hash": "docker.io/robotshop/rs-ratings@sha256:4899c686c249464783663342620425dc8c75a5d59ca55c247cf6aec62a5fff1a",
      "kubernetes.container_image": "docker.io/robotshop/rs-ratings:latest",
      "#repo": "aiops",
      "@timestamp": 1637337003872,
      "kubernetes.namespace_name": "robot-shop",
      "@timezone": "Z",
      "@rawstring": "2021-11-19T09:50:03.872288692-06:00 stdout F [2021-11-19 15:50:03] php.INFO: User Deprecated: Since symfony/http-kernel 5.4: \"Symfony\\Component\\HttpKernel\\Event\\KernelEvent::isMasterRequest()\" is deprecated, use \"isMainRequest()\" instead. {\"exception\":\"[object] (ErrorException(code: 0): User Deprecated: Since symfony/http-kernel 5.4: \\\"Symfony\\\\Component\\\\HttpKernel\\\\Event\\\\KernelEvent::isMasterRequest()\\\" is deprecated, use \\\"isMainRequest()\\\" instead. at /var/www/html/vendor/symfony/http-kernel/Event/KernelEvent.php:88)\"} []",
      "@id": "tiMU0F8kdNf6x0qMduS9T31q_269_400_1637337003",
      "kubernetes.pod_id": "09d64ec8-c09f-4650-871f-adde27ca863e",
      "#type": "unparsed",
      "kubernetes.annotations.cni_projectcalico_org/containerID": "337bf300371c84500756a6e94e58b2d8ee54a1b9d1bc7e38eb410f1c1bbd6991"
    }
  ],
  "numberOfEvents": 1
}
```

#### 15.4.1.2 On Humio:

- Create Action:

	* Use the Webbhook from EventManager/NOI
	* Select `Skip Certificate Validation`
	* Click `Test Action` and check that you get it in EventManager/NOI Events

<div style="page-break-after: always;"></div>

- Create Alert:

	* 	With Query (for example):
	
		```json
		"kubernetes.container_name" = ratings
		| @rawstring = /error/i
		```

	* 	Time Window 2 seconds
	* 	1 second throttle window
	* 	Add action from above
	
	

### 15.5 Easily simulate erros

Simulate MySQL error by cutting the communication with the Pod:

```bash
oc patch -n robot-shop service mysql -p '{"spec": {"selector": {"service": "mysql-deactivate"}}}'
```

Restore the communication:

```bash
oc patch -n robot-shop service mysql -p '{"spec": {"selector": {"service": "mysql"}}}'
```

<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 16 ServiceMesh
---------------------------------------------------------------

## 16.1 Installing ServiceMesh

Use Option 🐥`24` in [Easy Install](#-2-easy-install) to install a `ServiceMesh ` instance

## 16.2 Manually installing ServiceMesh
> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

You can easily install ServiceMesh/Istio into the same cluster as CP4WAIOPS.

This will instrument the RobotShop Application at the same time.

1. Launch

	```bash
	ansible-playbook ./ansible/29_install-servicemesh.yaml	
	```
	
2. Wait for the pods to come up
3. You can get the different URLs (RobotShop, Kibana, Grafana, Jaeger) by launching:

	```bash
	./tools/20_get_logins.sh > my_credentials.txt
	```


<div style="page-break-after: always;"></div>




---------------------------------------------------------------
# 17 AWX
---------------------------------------------------------------

## 17.1 Installing AWX

Use Option 🐥`23` in [Easy Install](#-2-easy-install) to install a `AWX ` instance

![K8s CNI](./doc/pics/install-evtmanager_awx.png)


## 17.2 Manually installing AWX

> ℹ️ Either position the option in the configuratoion file or follow the steps described in this chapter.

You can easily install AWX (OpenSource Ansible Tower) into the same cluster as CP4WAIOPS.

1. Launch

	```bash
	ansible-playbook ./ansible/23_install-awx.yaml	
	```
	
2. Wait for the pods to come up
3. You can get the URLs and access credentials by launching:

	```bash
	./tools/20_get_logins.sh > my_credentials.txt
	```



<div style="page-break-after: always;"></div>





---------------------------------------------------------------
# 18 Detailed Prerequisites
---------------------------------------------------------------


## 18.1 OpenShift requirements

I installed the demo in a ROKS environment.

You'll need:

- ROKS 4.8 (4.7 should work also)
- 5x worker nodes Flavor `b3c.16x64` (so 16 CPU / 64 GB)

You might get away with less if you don't install some components (Humio, Turbonomic,...)



## 18.2 Tooling

You need the following tools installed in order to follow through this guide:

- ansible
- oc (4.7 or greater)
- jq
- kubectl (Not needed anymore - replaced by `oc`)
- kafkacat (only for training and debugging)
- elasticdump (only for training and debugging)
- IBM cloudctl (only for LDAP)

<div style="page-break-after: always;"></div>

### 18.2.1 On Mac - Automated (preferred)

Use Option 🐥`71` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Mac`

#### 18.2.1.1 On Mac - Manual

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)

Or install them manually:


```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ansible
ansible-galaxy collection install community.kubernetes:1.2.1
ansible-galaxy collection install kubernetes.core:2.2.3
pip install openshift pyyaml kubernetes 
brew install kafkacat
brew install node
brew install wget
npm install elasticdump -g
brew install jq

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-darwin-amd64.tar.gz -o cloudctl-darwin-amd64.tar.gz
tar xfvz cloudctl-darwin-amd64.tar.gz
sudo mv cloudctl-darwin-amd64 /usr/local/bin/cloudctl
rm cloudctl-darwin-amd64.tar.gz

```


Get oc and kubectl (optional) from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.8.0-0.okd-2021-11-14-052418/openshift-client-mac-4.8.0-0.okd-2021-11-14-052418.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin.  (this is optional)
rm oc.tar.gz
rm README.md
```



I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Darwin_x86_64.tar.gz
tar xfzv k9s_Darwin_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```


<div style="page-break-after: always;"></div>

### 18.2.2 On Ubuntu Linux - Automated (preferred) 

Use Option 🐥`72` in [Easy Install](#-2-easy-install) to install the `Prerequisites for Ubuntu`


#### 18.2.2.1 On Ubuntu Linux - Manual

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)

Or install them manually:


`sed` comes preinstalled

```bash
sudo apt-get install -y ansible
ansible-galaxy collection install community.kubernetes:1.2.1
ansible-galaxy collection install kubernetes.core:2.2.3
pip install openshift pyyaml kubernetes 
sudo apt-get install -y kafkacat
sudo apt-get install -y npm
sudo apt-get install -y jq
sudo npm install elasticdump -g

curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz
tar xfvz cloudctl-linux-amd64.tar.gz
sudo mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
rm cloudctl-linux-amd64.tar.gz

```

Get oc and oc from [here](https://github.com/openshift/okd/releases/)

or use :

```bash
wget https://github.com/openshift/okd/releases/download/4.8.0-0.okd-2021-11-14-052418/openshift-client-linux-4.8.0-0.okd-2021-11-14-052418.tar.gz -O oc.tar.gz
tar xfzv oc.tar.gz
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin
rm oc.tar.gz
rm README.md
```

I highly recomment installing the `k9s` tool :

```bash
wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xfzv k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/local/bin
rm LICENSE
rm README.md
```

<div style="page-break-after: always;"></div>

## 18.3 Get the scripts and code from GitHub


### 18.3.1 Clone the GitHub Repository (preferred)

And obviosuly you'll need to download this repository to use the scripts.


```
git clone https://<YOUR GIT TOKEN>@github.ibm.com/NIKH/aiops-install-ansible.git 
```

You can create your GIT token [here](https://github.ibm.com/settings/tokens).

#### 18.3.1.1 Refresh the code from GitHub

Make sure you have the latest version:

```
git checkout origin/master -f | git checkout master -f | git pull origin master
```

Or create an alias for reuse:

```
alias gitrefresh='git checkout origin/master -f | git checkout master -f | git pull origin master'
```

### 18.3.2 Download the GitHub Repository in a ZIP (not preferred)

Simply click on the green `CODE` button and select `Download Zip` to download the scripts and code.

❗ If there are updates you have to re-download the ZIP.


<div style="page-break-after: always;"></div>


---------------------------------------------------------------
# 19 Detailed CP4WAIOPS Installation
---------------------------------------------------------------



## 19.1 Manually install AI Manager (Optional)

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)



### 19..1.1 Adapt configuration

Adapt the `00_config_cp4waiops.yaml` file with the desired parameters:


#### 19.1.1.1 Automatic Login

The Playbook provides the means to automatically login to the cluster by filling out the following section of the config file:

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# OCP LOGIN PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************
OCP_LOGIN: true
OCP_URL: https://c100-e.eu-gb.containers.cloud.ibm.com:31513
OCP_TOKEN: sha256~T6-cxxxxxxxxxxxx-dtuj3ELQfpioUhHms

#Version of your OCP Cluster (override by setting manually - 4.6, 4.7,...)
OCP_MAJOR_VERSION: automatic
```

<div style="page-break-after: always;"></div>

#### 19.1.1.2 Adapt AI Manager Config

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS AI Manager INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************

# CP4WAIOPS Namespace for installation
WAIOPS_NAMESPACE: cp4waiops

# CP4WAIOPS Size of the install (small: PoC/Demo, tall: Production)
WAIOPS_SIZE: small # Leave at small unless you know what you're doing
# Version of the catalog subscription
SUBSCRIPTION_CHANNEL: v3.2

# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS Storage Class Override
# -------------------------------------------------------------------------------------
# *************************************************************************************

# Override the Storage Class auto detection (ibmc-file-gold-gid, rook-cephfs, nfs-client, ...)
STORAGECLASS_FILE_OVERRIDE: not_configured
STORAGECLASS_BLOCK_OVERRIDE: not_configured

```


> There is no need to manually define the Storage Class anymore.
> The Playbook sets the storage class to `ibmc-file-gold-gid` for ROKS and `rook-cephfs` for Fyre.
> Otherwise it uses the default Storage Class.

> It is possible to override the Storage Class detection and force a custom Storage Class by setting `STORAGECLASS_XXX_OVERRIDE` in the config file.


<div style="page-break-after: always;"></div>



#### 19.1.1.3 Adapt Event Manager Config


```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# CP4WAIOPS Event Manager INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************

# CP4WAIOPS Namespace for installation
EVTMGR_NAMESPACE: cp4waiops-evtmgr

```
<div style="page-break-after: always;"></div>

#### 19.1.1.4 Adapt Demo Components

```bash
# *************************************************************************************
# -------------------------------------------------------------------------------------
# DEMO INSTALL PARAMETERS
# -------------------------------------------------------------------------------------
# *************************************************************************************

# Create a demo user in the OCP cluster
CREATE_DEMO_USER: true

# Install Demo Applications
INSTALL_DEMO_APPS: true

# Print all credentials at the end of the installation
PRINT_LOGINS: true

# Install Bastion Server for Runbook Automation
INSTALL_RUNBOOK_BASTION: true

```

<div style="page-break-after: always;"></div>

#### 19.1.1.4 Adapt Optional Components

```bash
# ******************************************************************************
# ------------------------------------------------------------------------------
# MODULE INSTALL PARAMETERS
# ------------------------------------------------------------------------------
# ******************************************************************************
# Install Rook-Ceph (Should Rook-Ceph be installed (automatic: install when on IBM Fyre) (enable, automatic, disable))
ROOK_CEPH_INSTALL_MODE: automatic

# Install LDAP Server
INSTALL_LDAP: true
# LDAP Domain
LDAP_DOMAIN: ibm.com
# LDAP Base
LDAP_BASE: dc=ibm,dc=com
# LDAP Admin Password
LDAP_ADMIN_PASSWORD: P4ssw0rd!

# Install Turbonomic (experimental - needs separate license)
INSTALL_TURBONOMIC: false
# Turbonomic Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_TURBO: ibmc-block-gold
# Install Turbonomic Metrics simulation (highly experimental!)
INSTALL_TURBONOMIC_METRICS: false
# Install Turbonomic --> Event Manager Gateway (highly experimental!)
INSTALL_TURBONOMIC_GATEWAY: false

# Install Humio (needs separate license)
INSTALL_HUMIO: false
# Humio Storage Class (ibmc-block-gold, rook-cephfs, nfs-client, ...)
STORAGE_CLASS_HUMIO: ibmc-block-gold

# Install ELK Stack
INSTALL_ELK: false

# Install ServiceMesh/Istio
INSTALL_ISTIO: false

# Install AWX (Open Source Ansible Tower)
INSTALL_AWX: false

# Install ManageIQ (Open Source CloudForms)
INSTALL_MANAGEIQ: false
```

<div style="page-break-after: always;"></div>

### 19.1.2 Get the installation token

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

This token is being referred to as <PULL_SECRET_TOKEN> below and should look something like this (this is NOT a valid token):

```yaml
eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY  
```

<div style="page-break-after: always;"></div>

### 19.1.3 🚀 Start installation

Just run:

```bash
./10_install_ai_manager.sh -t <PULL_SECRET_TOKEN> [-v true]


Example:
./10_install_ai_manager.sh -t eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:


- CP4WAIOPS AI Manager
- OpenLDAP (if enabled)
- Demo Apps (if enabled)
- Register LDAP Users (if enabled)
- Housekeeping
	- Additional Routes (Topology, Flink)
	- Create OCP User (serviceaccount demo-admin)
	- Patch Ingress
	- Adapt NGINX Certificates
	- Adapt Slack Welcome message to /welcome
- Turbonomic (if enabled)
- Humio (if enabled)
- OCP ELK Stack (if enabled)
- AWX (Open Source Ansible Tower - if enabled)
- ManageIQ (Open Source CloudForms - if enabled)

<div style="page-break-after: always;"></div>


### 19.1.4 Configure LDAP Users

1. Log in to AI Manager as admin
2. Select `Administration/Access` control from the "Hamburger manu"
3. Click on the `Identity provider configuration` (upper right) you should get the LDAP being registered
4. Go back
5. Select `User Groups Tab`
6. Click `New User Group`
7. Call it `demo`
8. Click `Next`
9. Click on `Identity provider groups`
10. Search for `demo`
11. Select `cn=demo,ou=Groups,dc=ibm,dc=com`
12. Click `Next`
13. Select `Administrator` rights
14. Click `Next`
15. Click `Create`

Now you will be able to login with all LDAP users that are part of the demo group (for example demo/P4ssw0rd!).

You can check/modify those in the OpenLDAPAdmin interface that you can access with the credentials described in 3.3.





<div style="page-break-after: always;"></div>



## 19.3 Manually install EventManager (Optional)

Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)



### 19.3.1 Get the installation token

You can get the installation (pull) token from [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary).

This allows the CP4WAIOPS images to be pulled from the IBM Container Registry.

This token is being referred to as <PULL_SECRET_TOKEN> below and should look something like this (this is NOT a valid token):

```yaml
eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY  
```

To get the token, see [here](#3.1.2-get-the-installation-token) 



### 19.3.2 🚀 Start installation

Just run:

```bash
./11_install_event_manager.sh -t <PULL_SECRET_TOKEN> [-v true]


Example:
./11_install_event_manager.sh -t eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:

- CP4WAIOPS EventManager
- Gateway





<div style="page-break-after: always;"></div>


## 19.4 Get Passwords and Credentials

At any moment you can run `./tools/20_get_logins.sh` that will print out all the relevant passwords and credentials.

Usually it's a good idea to store this in a file for later use:

```bash
./tools/20_get_logins.sh > my_credentials.txt
```

## 19.5 Check status of installation

At any moment you can run `./tools/11_check_install.sh` or for a more in-depth examination and troubleshooting `./tools/10_debug_install.sh` and select `Option 1` to check your installation.


<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 20 Additional Configuration
---------------------------------------------------------------

## 20.1 Setup remote Kubernetes Observer



### 20.1.1 Get Kubernetes Cluster Access Details

As part of the kubernetes observer, it is required to communicate with the target cluster. So it is required to have the URL and Access token details of the target cluster. 

Do the following.


#### 20.1.1.1 Login

Login into the remote Kubernetes cluster on the Command Line.

#### 20.1.1.2 Access user/token 


Run the following:

```
./tools/97_addons/k8s-remote/remote_user.sh
```

This will create the remote user if it does not exist and print the access token (also if you have already created).

Please jot this down.



### 20.1.1 Create Kubernetes Observer Connection



* In the `AI Manager` "Hamburger" Menu select `Operate`/`Data and tool integrations`
* Click `Add connection`
* Under `Kubernetes`, click on `Add Integration`
* Click `Connect`
* Name it `RobotShop`
* Data Center `demo`
* Click `Next`
* Choose `Load` for Connection Type
* Input the URL you have gotten from the step above in `Kubernetes master IP address` (without the https://)
* Input the port for the URL you have gotten from the step above in `Kubernetes API port`
* Input the `Token` you have gotten from the step above
* Set `Trust all certificates by bypassing certificate verification` to `On`
* Set `Hide pods that have been terminated` to `On`
* Set `Correlate analytics events on the namespace groups created by this job` to `On`
* Set Namespace to `robot-shop`
* Click `Next`
* Click `Done`


![](./doc/pics/k8s-remote.png)



## 20.2 AiManager Event Gateway

A Simple Webhook to Kafka Gateway for CP4WAIOPS.
This allows you to push generic JSON to AIManager Events throught a Webhook into Kafka.

> Source code is included if you want to mess around a bit.


### 20.2.1 Message mapping Parameters

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





### 20.2.2 Getting the Kafka Conncetion Parameters

This gives you the Parameters for the Kafka Connection that you have to modify in the `cp4waiops-event-gateway-config` ConfigMap in file `./tools/97_addons/webhook/create-cp4mcm-event-gateway.yaml`.

```bash
export WAIOPS_NAMESPACE=cp4waiops
export KAFKA_TOPIC=$(oc get kafkatopics -n $WAIOPS_NAMESPACE | grep -v cp4waiopscp4waiops| grep cp4waiops-cartridge-alerts-$EVENTS_TYPE| awk '{print $1;}')
export KAFKA_USER=$(oc get secret ibm-aiops-kafka-secret -n $WAIOPS_NAMESPACE --template={{.data.username}} | base64 --decode)
export KAFKA_PWD=$(oc get secret ibm-aiops-kafka-secret -n $WAIOPS_NAMESPACE --template={{.data.password}} | base64 --decode)
export KAFKA_BROKER=$(oc get routes iaf-system-kafka-0 -n $WAIOPS_NAMESPACE -o=jsonpath='{.status.ingress[0].host}{"\n"}'):443
export CERT_ELEMENT=$(oc get secret -n $WAIOPS_NAMESPACE kafka-secrets  -o 'go-template={{index .data "ca.crt"}}'| base64 -d)

echo "KAFKA_BROKER: '"$KAFKA_BROKER"'"
echo "KAFKA_USER: '"$KAFKA_USER"'"
echo "KAFKA_PWD: '"$KAFKA_PWD"'"
echo "KAFKA_TOPIC: '"$KAFKA_TOPIC"'"
echo "CERT_ELEMENT:  |- "
echo $CERT_ELEMENT

```

> You will have to indent the Certificate!



### 20.2.2 Deploying 

```bash
oc apply -n default -f ./tools/97_addons/k8s-remote/create-cp4mcm-event-gateway.yaml

oc get route -n cp4waiops cp4waiops-event-gateway  -o jsonpath={.spec.host}

```


### 20.2.3 Using the Webhook

For the following example we will iterate over the `events` array and epush them to mapped version to Kafka:


```bash
curl -X "POST" "http://cp4waiops-event-gateway-cp4waiops.itzroks-270003bu3k-azsa8n-6ccd7f378ae819553d37d5f2ee142bd6-0000.us-south.containers.appdomain.cloud/webhook" \
     -H 'Content-Type: application/json' \
     -H 'Cookie: 36c13f7095ac25e696d30d7857fd2483=e345512191b5598e33b76be85dd7d3b6' \
     -d $'{
  "numberOfEvents": 3,
  "repository": "aiops",
  "timestamp": "2021-11-19T15:50:04.958Z",
  "alert": {
    "id": "rCA2w5zaIE6Xr3RKlFfhAxqqbGqGxGLC",
    "query": {
      "end": "now",
      "queryString": "\\"kubernetes.container_name\\" = ratings| @rawstring = /error/i ",
      "start": "2s"
    },
    "name": "MyAlert",
    "description": "",
    "notifierID": "Rq4a9KUbomSIBvEcdC7kzzmdBtPI3yPb"
  },
  "events": [
    {
      "@rawstring": "Message 1",
      "@timestamp": 1639143464971,
      "kubernetes.container_name": "ratings",
      "kubernetes.namespace_name": "robot-shop",
    },
    {
      "@rawstring": "Message 2",
      "@timestamp": 1639143464982,
      "kubernetes.container_name": "catalogue",
      "kubernetes.namespace_name": "robot-shop",
    },
    {
      "@rawstring": "Message 3",
      "@timestamp": 1639143464992,
      "kubernetes.container_name": "web",
      "kubernetes.namespace_name": "robot-shop",
    }
  ],
  "warnings": ""
}'
```


<div style="page-break-after: always;"></div>

---------------------------------------------------------------
# 21 Service Now integration
---------------------------------------------------------------



## 21.1 Integration 

1. Follow [this](./doc/servicenow/snow-Integrate.md) document to get and configure your Service Now Dev instance with CP4WAIOPS.
	Stop at `Testing the ServiceNow Integration`. 
	❗❗Don’t do the training as of yet.
2. Import the Changes from ./doc/servicenow/import_change.xlsx
	1. Select `Change - All` from the right-hand menu
	2. Right Click on `Number`in the header column
	3. Select Import
	![](./doc/pics/snow3.png)
	3. Chose the ./doc/servicenow/import_change.xlsx file and click `Upload`
	![](./doc/pics/snow4.png)
	3. Click on `Preview Imported Data`
	![](./doc/pics/snow5.png)
	3. Click on `Complete Import` (if there are errors or warnings just ignore them and import anyway)
	![](./doc/pics/snow6.png)
	
3. Import the Incidents from ./doc/servicenow/import_incidents.xlsx
	1. Select `Incidents - All` from the right-hand menu
	2. Proceed as for the Changes but for Incidents
	
4. Now you can finish configuring your Service Now Dev instance with CP4WAIOPS by [going back](./doc/servicenow/snow-Integrate.md#testing-the-servicenow-integration) and continue whre you left off at `Testing the ServiceNow Integration`. 




<div style="page-break-after: always;"></div>



---------------------------------------------------------------
# 22 Manually train the models
---------------------------------------------------------------



Only do this if you don't want to use 🐥 [Easy Install](#-2-easy-install)

### 22.3.1 Load Training Data

#### 22.3.1.1 Create ElasticSearch Port Forward

Please start port forward in **separate** terminal.

Use the script that does it automatically:

```bash
./tools/28_access_elastic.sh
```

or run the following:

```bash
while true; do oc port-forward statefulset/iaf-system-elasticsearch-es-aiops 9200; done
```
#### 22.3.1.2 Load Training Data into ElasticSearch

Run the following scripts to inject training data:
	
```bash
./56_load_robotshop_data.sh
```

This takes some time (20-60 minutes depending on your Internet speed).

<div style="page-break-after: always;"></div>

### 22.3.2 Train Log Anomaly

#### 22.3.2.1 Create Training Definition for Log Anomaly

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Log anomaly detection - natural language`  click on `Configure`
* Click `Next`
* Name it `LogAnomaly`
* Click `Next`
* Select `Custom`
* Select `05/05/21` (May 5th 2021 - dd/mm/yy) to `07/05/21` (May 7th 2021) as date range (this is when the logs we're going to inject have been created)
* Click `Next`
* Click `Next`
* Click `Create`


#### 22.3.2.2 Train the Log Anomaly model

* Click on the `Manager` Tab
* Click on the `LogAnomaly` entry
* Click `Start Training`
* This will start a precheck that should tell you after a while that you are ready for training ant then start the training

After successful training you should get: 

![](./doc/pics/training1.png)

* Click on `Deploy vXYZ`


⚠️ If the training shows errors, please make sure that the date range of the training data is set to May 5th 2021 through May 7th 2021 (this is when the logs we're going to inject have been created)


<div style="page-break-after: always;"></div>

## 22.3.3 Train Event Grouping

#### 22.3.3.1 Create Training Definition for Event Grouping

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Temporal grouping` click on `Configure`
* Click `Next`
* Name it `EventGrouping`
* Click `Next`
* Click `Done`


#### 22.3.3.2 Train the Event Grouping Model


* Click on the `Manager` Tab
* Click on the `EventGrouping ` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training2.png)

* The model is deployed automatically






<div style="page-break-after: always;"></div>

## 22.3.4 Train Incident Similarity

#### ❗ Only needed if you don't plan on doing the Service Now Integration


#### 22.3.4.1 Create Training Definition

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Similar incidents` click on `Configure`
* Click `Next`
* Name it `SimilarIncidents`
* Click `Next`
* Click `Next`
* Click `Done`


#### 22.3.4.2 Train the Incident Similarity Model


* Click on the `Manager` Tab
* Click on the `SimilarIncidents` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training3.png)

* The model is deployed automatically




<div style="page-break-after: always;"></div>

## 22.3.5 Train Change Risk

#### ❗ Only needed if you don't plan on doing the Service Now Integration


#### 22.3.5.1 Create Training Definition

* In the `AI Manager` "Hamburger" Menu select `Operate`/`AI model management`
* Under `Change risk` click on `Configure`
* Click `Next`
* Name it `ChangeRisk`
* Click `Next`
* Click `Next`
* Click `Done`


#### 22.3.5.2 Train the Change Risk Model


* Click on the `Manager` Tab
* Click on the `ChangeRisk ` entry
* Click `Start Training`
* This will start the training

After successful training you should get: 

![](./doc/pics/training4.png)

* Click on `Deploy vXYZ`



-----------------------------------------------------------------------------------
# 99 Example Installation Log
---------------------------------------------------------------


```bash
--------------------------------------------------------------------------------------------
 🚀  Install CP4WAIOPS AI Manager
--------------------------------------------------------------------------------------------


  🔐 You have provided the following Token:
    eyJhbGciOiJIUzaaaaaaa.....aaaaaaaax4m9EH-abvdc53DYEkbYY

  Are you sure that this is correct❓ [y,N] y
  Do you want to install demo content (highly recommended - OpenLdap and RobotShop)❓ [Y,n] y

   ✅ Ok, continuing with demo content...



[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] *******************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************
ok: [localhost]

TASK [00_pre : PREREQUISITES -      👓 Load parameters] ****************************************************************************************************************************************
ok: [localhost]

TASK [01_initialization : PREREQUISITES -      👓 Load parameters] *****************************************************************************************************************************
ok: [localhost]

TASK [01_initialization : PREREQUISITES -      📥  Installing in Namespace "cp4waiops" with size "small"] **************************************************************************************
ok: [localhost]

TASK [01_initialization : PREREQUISITES -      📥  Installation Parameters"] *******************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "** CP4WAIOPS AI Manager Parameters ***********************************************************************",
        " AI Manager Installation Name:      ibm-aiops",
        " AI Manager Namespace:              cp4waiops",
        " AI Manager Installation Size:      small",
        "",
        "** Installation Options ***********************************************************************",
        " Rook-Ceph installation method:    automatic",
        " Auto Login for OCP:               False",
        "    OCP Url:                        not_configured",
        "    OCP Token:                      not_configured",
        " OCP Major Version:                automatic",
        " Storage Class File Override:      not_configured",
        " Storage Class Block Override:     not_configured",
        "",
        "** Additional Content *************************************************************************",
        " Create a demo user:               True",
        " Install Demo Applications:        True",
        " Install Bastion Server (RBA):     True",
        " Install LDAP Server:              True",
        "  LDAP Domain:                     ibm.com",
        "  LDAP Base:                       dc=ibm,dc=com",
        "  LDAP Admin Password:             P4ssw0rd!",
        " Install Turbonomic:               False",
        "     Turbonomic Storage Class:      ibmc-block-gold",
        " Install Humio:                    False",
        " Install OCP ELK Stack:            False"
    ]
}

TASK [01_initialization : PLATFORM -           🌏 Get Cluster FQDN] ****************************************************************************************************************************
changed: [localhost]

TASK [01_initialization : ROOKCEPH -           💾 Set Global Cluster Name=xxx-0000.eu-de.containers.appdomain.cloud] ********************
ok: [localhost]

TASK [01_initialization : PLATFORM -           🔎  Check if Rook-Ceph should be installed for mode automatic] **********************************************************************************
changed: [localhost]

TASK [01_initialization : ROOKCEPH -           💾 Install Rook-Ceph=false] *********************************************************************************************************************
ok: [localhost]

TASK [01_initialization : OPENSHIFT VERSION -  ☑️  Determine OpenShift Major Version] **********************************************************************************************************
changed: [localhost]

TASK [01_initialization : OPENSHIFT VERSION -  💾 Set OCP_MAJOR_VERSION=4.8] *******************************************************************************************************************
ok: [localhost]

TASK [02_rook-ceph : ROOKCEPH -           🔎 Check if Rook-Ceph should be installed] ***********************************************************************************************************
ok: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       👓 Load parameters] ********************************************************************************************************************
ok: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       🌏 Get Cluster FQDN] *******************************************************************************************************************
changed: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       ☑️  Determine File Storage Class] ******************************************************************************************************
changed: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       ☑️  Determine Block Storage Class] *****************************************************************************************************
changed: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       💾 Set WAIOPS_STORAGE_CLASS_FILE=ibmc-file-gold-gid] ***********************************************************************************
ok: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       💾 Set WAIOPS_STORAGE_CLASS_LARGE_BLOCK=ibmc-block-gold] *******************************************************************************
ok: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       ☑️  Check File Storage Class exists ibmc-file-gold-gid] ********************************************************************************
changed: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       ☑️  Check Large Block Storage Class exists ibmc-block-gold] ****************************************************************************
changed: [localhost]

TASK [03_aiops-get-storage-class : STORAGECLASS -       💿 Storage Class] **********************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "** Global Storage Classes for CP4WAIOPS installation *************************************************************************",
        " CP4WAIOPS Storage Class File:          ibmc-file-gold-gid",
        " CP4WAIOPS Storage Class Large Block:   ibmc-block-gold"
    ]
}

TASK [04_aiops-prerequisites : PREREQUISITES -      👓 Load parameters] ************************************************************************************************************************
ok: [localhost]

TASK [04_aiops-prerequisites : PREREQUISITES -      🚀 Create CP4WAIOPS namespace cp4waiops] ***************************************************************************************************
changed: [localhost]

TASK [04_aiops-prerequisites : PREREQUISITES -      🚀 Create Pull Secret] *********************************************************************************************************************
changed: [localhost]

TASK [04_aiops-prerequisites : PREREQUISITES -      🚀 Create aiops-topology-service-account] **************************************************************************************************
changed: [localhost]

TASK [10_aiops-operator : AI Manager -           🚀 Install IBM Operator Catalog] **************************************************************************************************************
changed: [localhost]

TASK [10_aiops-operator : AI Manager -           🚀 Install Operator Group] ********************************************************************************************************************
changed: [localhost]

TASK [10_aiops-operator : AI Manager -           🚀 Install Subscription] **********************************************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -              🕦 Wait for CSVs to become ready (500 retries left).
...

TASK [10_aiops-operator : CHECK -              🕦 Wait for CSVs to become ready] ***************************************************************************************************************
changed: [localhost]

TASK [11_aiops-install : AI Manager -         🚀 Install Custom Resource - INSTALL AI MANAGER] *************************************************************************************************
changed: [localhost]

TASK [25_aiops-addons-ldap : LDAP -               🚀 Install OpenLDAP] *************************************************************************************************************************
changed: [localhost]

TASK [26_aiops-addons-user : USER -               🔎 Check OCP Demouser Account] ***************************************************************************************************************
ok: [localhost]

TASK [26_aiops-addons-user : USER -               🩹 Create OCP Demouser Account] ****************************************************************************************************************
changed: [localhost]

TASK [27_aiops-addons-demoapps : DEMO -               🔎 Check RobotShop] **********************************************************************************************************************
ok: [localhost]

TASK [27_aiops-addons-demoapps : DEMO -               🚀 Create robot-shop namespace] **********************************************************************************************************
changed: [localhost]

TASK [27_aiops-addons-demoapps : DEMO -               🚀 Create robot-shop service account] ****************************************************************************************************
changed: [localhost]

TASK [27_aiops-addons-demoapps : DEMO -               🚀 Create robot-shop application] ********************************************************************************************************
changed: [localhost]

TASK [27_aiops-addons-demoapps : DEMO -               🚀 Create robot-shop load generation] ****************************************************************************************************
changed: [localhost]

TASK [28_aiops-addons-runbook-bastion : BASTION -            🔎 Check Runbook Bastion Server] **************************************************************************************************
ok: [localhost]

TASK [28_aiops-addons-runbook-bastion : BASTION -            🚀 Install Runbook Bastion Server] ************************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -          🕦 Wait for more than >35 pods in namespace ibm-common-services (500 retries left).
...

TASK [99_aiops-wait-common-services : CHECK -          🕦 Wait for more than >35 pods in namespace ibm-common-services] ************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -          🕦 Wait for ibm-common-services to become ready (500 retries left).
...


TASK [99_aiops-wait-common-services : CHECK -          🕦 Wait for ibm-common-services to become ready] ****************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -          🕦 Wait for Zen Ansible Script zen_ready.stdout in namespace ibm-common-services (500 retries left).
...

TASK [99_aiops-wait-for-zen : CHECK -          🕦 Wait for Zen Ansible Script zen_ready.stdout in namespace ibm-common-services] ***************************************************************
changed: [localhost]

TASK [30_aiops-patches : PATCH    -             🩹 Patch Ingress] ********************************************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES -               🔎 Check Topology Routes] **********************************************************************************************************************
ok: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create Topology Route - topology-merge] ****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create Topology Route - topology-rest] *****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create Topology Route - topology-file] *****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create Topology Route - topology-manage] ***************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create external Flink Job Manager Route (you can ignore errors in this step)] **************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create external AI Manager API Route (you can ignore errors in this step)] *****************************************************************
changed: [localhost]

TASK [30_aiops-patches : ROUTES    -             🚀 Create external Datalayer API Route (you can ignore errors in this step)] ******************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: HACK    -             🕦 Wait for Cassandra Pod to become available - this can take up to 45 minutes (hack for 3.2) (500 retries left).
...

TASK [30_aiops-patches : HACK    -             🕦 Wait for Cassandra Pod to become available - this can take up to 45 minutes (hack for 3.2)] **************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-service-account (hack for 3.2)] *******************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: HACK    -             🕦 Wait for Topology Pods to become available - this can take up to 45 minutes (hack for 3.2) (500 retries left).
...

FAILED - RETRYING: [localhost]: HACK    -             🕦 Wait for Cassandra Pod to become available - this can take up to 45 minutes (hack for 3.2) (475 retries left).

TASK [30_aiops-patches : HACK    -             🕦 Wait for Cassandra Pod to become available - this can take up to 45 minutes (hack for 3.2)] **************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-service-account (hack for 3.2)] *******************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: HACK    -             🕦 Wait for Topology Pods to become available - this can take up to 45 minutes (hack for 3.2) (500 retries left).
...

TASK [30_aiops-patches : HACK    -             🕦 Wait for Topology Pods to become available - this can take up to 45 minutes (hack for 3.2)] **************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-merge (hack for 3.2)] *****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-search (hack for 3.2)] ****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-status (hack for 3.2)] ****************************************************************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch aiops-topology-layout (hack for 3.2)] ****************************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: HACK    -             🕦 Wait for IR Analytics Pods to become available - this can take up to 45 minutes (hack for 3.2) (500 retries left).
...


TASK [30_aiops-patches : HACK    -             🕦 Wait for IR Analytics Pods to become available - this can take up to 45 minutes (hack for 3.2)] **********************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Patch IR Analytics Pods (hack for 3.2) (you can ignore errors in this step)] *******************************************************************
changed: [localhost]

TASK [30_aiops-patches : HACK    -             🩹 Delete Pods with ImgPull Error (hack for 3.2)  (you can ignore errors in this step)] ***********************************************************
fatal: [localhost]: FAILED! => {"changed": true, "cmd": "oc delete pod --ignore-not-found $(oc get po -n cp4waiops|grep ImagePull|awk '{print$1}') -n cp4waiops\n", "delta": "0:00:01.351690", "end": "2022-02-21 10:36:15.723159", "msg": "non-zero return code", "rc": 1, "start": "2022-02-21 10:36:14.371469", "stderr": "error: resource(s) were provided, but no name, label selector, or --all flag specified", "stderr_lines": ["error: resource(s) were provided, but no name, label selector, or --all flag specified"], "stdout": "", "stdout_lines": []}
...ignoring

TASK [99_aiops-wait-cp4waiops : CHECK -          🕦 Wait for more than >110 pods in namespace cp4waiops] ***************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -          🕦 Wait for cp4waiops to become ready (500 retries left).
...

TASK [99_aiops-wait-cp4waiops : CHECK -          🕦 Wait for cp4waiops to become ready] ********************************************************************************************************
changed: [localhost]
FAILED - RETRYING: [localhost]: CHECK -          🕦 Wait for all Pods in cp4waiops to become ready (500 retries left).
...

TASK [99_aiops-wait-cp4waiops : CHECK -          🕦 Wait for all Pods in cp4waiops to become ready] ********************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : SLACK -                🕦 Wait for Slack Pod Ready] *************************************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : NETWORK -              🩹 Patch NetworkPolicy] ********************************************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : CERTIFICATES -         🩹 Patch AutomationUIConfig Certificates] **************************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : CERTIFICATES -         🩹 Patch Ingress Certificates (you can ignore errors in this step)] ************************************************************************
fatal: [localhost]: FAILED! => {"msg": "template error while templating string: expected token 'end of print statement', got 'string'. String: ingress_pod=$(oc get secrets -n openshift-ingress | grep tls | grep -v router-metrics-certs-default | awk '{print $1}')\noc get secret -n openshift-ingress -o 'go-template={{index .data \"tls.crt\"}}' ${ingress_pod} | base64 -d > cert.crt\noc get secret -n openshift-ingress -o 'go-template={{index .data \"tls.key\"}}' ${ingress_pod} | base64 -d > cert.key\noc get secret -n {{ WAIOPS_NAMESPACE }} iaf-system-automationui-aui-zen-ca -o 'go-template={{index .data \"ca.crt\"}}'| base64 -d > ca.crt\n\noc get secret -n {{ WAIOPS_NAMESPACE }} external-tls-secret --ignore-not-found -o yaml > external-tls-secret.yaml\noc delete secret -n {{ WAIOPS_NAMESPACE }} --ignore-not-found external-tls-secret\noc create secret generic -n {{ WAIOPS_NAMESPACE }} external-tls-secret --from-file=ca.crt=ca.crt --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | oc apply -f -\nREPLICAS=2\noc scale Deployment/ibm-nginx --replicas=0\nsleep 3\noc scale Deployment/ibm-nginx --replicas=${REPLICAS}\n# rm cert.crt\n# rm cert.key\n# rm ca.crt\n# rm external-tls-secret.yaml\n"}
...ignoring

TASK [31_aiops-final-patches : CERTIFICATES -         🕦 Wait for AutomationUIConfig being ready] **********************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : CERTIFICATES -         🕦 Wait for nginx coming back up] ********************************************************************************************************
changed: [localhost]

TASK [31_aiops-final-patches : SLACK -                🩹 Patch Slack Welcome Message] ************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       🌏 Get Cluster FQDN] ******************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Get CS Server] *********************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Get CS Server IP] ******************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Get CS Server Password] ************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 SC Login] **************************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : DEBUG -                 🟢 Output] ***************************************************************************************************************************
ok: [localhost] => {
    "LOGIN.stdout_lines": [
        "Authenticating...",
        "OK",
        "",
        "Targeted account mycluster Account",
        "",
        "Targeted namespace kube-system",
        "",
        "Configuring kubectl ...",
        "Property \"clusters.mycluster\" unset.",
        "Property \"users.mycluster-user\" unset.",
        "Property \"contexts.mycluster-context\" unset.",
        "Cluster \"mycluster\" set.",
        "User \"mycluster-user\" set.",
        "Context \"mycluster-context\" created.",
        "Switched to context \"mycluster-context\".",
        "OK",
        "",
        "Configuring helm: /Users/nhirt/.helm",
        "OK"
    ]
}

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       🔎 Check already registered] **********************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : DEBUG -                 🟢 Output] ***************************************************************************************************************************
ok: [localhost] => {
    "LDAPS.stdout_lines": []
}

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Register LDAP Server] **************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : DEBUG -                 🟢 Output] ***************************************************************************************************************************
ok: [localhost] => {
    "LOGIN.stdout_lines": [
        "LDAP connection LDAP 'df331930-92fa-11ec-9c5b-8dd6e59652c6' successfully created"
    ]
}

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Get Team ID] ***********************************************************************************************************************
changed: [localhost]

TASK [40_aiops-post-ldap-register : LDAPREGISTER -       📥 Register Users and Teams] **********************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : PREREQUISITES -  🌏 Get Cluster FQDN] **********************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -  🚀 WAIOPS] ****************************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 WAIOPS] ********************************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "CloudPak for Watson AIOps",
        "**********************************************************************************************************************************",
        "CP4WAIOPS",
        "**********************************************************************************************************************************",
        "    AIOPS:",
        "        URL:      https://cpd-cp4waiops.xxx-0000.eu-de.containers.appdomain.cloud",
        "        ADMIN USER:",
        "         User:     admin",
        "         Password: aaaaa",
        " ",
        "    Administration hub / Common Services",
        "        URL:      https://cp-console.xxx-0000.eu-de.containers.appdomain.cloud",
        "        User:     admin",
        "        Password: aaaa",
        " ",
        " ",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - EventManager] *************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : LOGIN -  🚀 OCP Demo User] *********************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 OCP Demo User] *************************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "OCP Connection Details",
        "**********************************************************************************************************************************",
        "        URL:     https://c115-e.eu-de.containers.cloud.ibm.com:30205",
        "        Token:   eyJhbGciOiJSUzI1NiIsIaaaaaaJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tYWRtaW4tdG9rZW4tNjg1MmsiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtby1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImI0MDcyY2ZlLTdhZWYtNDc1OC05YmQzLWE5Y2M4OWZhMDAyNCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlbW8tYWRtaW4ifQ.wy8aku1jvUBSH3_F7Uo3p4r2Iud60kNuRa5lgxM0I8bdBg96fagzZa95jXfbfmsfVPmXv6iRYWeAaJemjMnj0h-SaqyR4yXwoKpP-MtFF_Yq3wGrbbt3_FQ-alT-ejaI0M--AYOGVJmSh8aU2TFWUTmj3hwEhOGmmwmc7XrUPd_EUGfKKpl5swEWl0p92PczlV4yQPeZ3eu_iCvQExifsYxAU7bfqhesOkaffXSACCkBWBk3VzYHlHzHQg1XOgeWA4Hq03QiMPODF3Fx1MQ9LEotaP8y7PJYQeOeqyDQbg9kGtodrbrBTy-CZKQeBSP8JRKvGWNwc4OF4xLRy51nKw",
        "",
        "",
        "",
        "        Login:   oc login --token=eyJhbGciOiJSUzI1NiIsImtpZaaaaaaJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlbW8tYWRtaW4tdG9rZW4tNjg1MmsiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVtby1hZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImI0MDcyY2ZlLTdhZWYtNDc1OC05YmQzLWE5Y2M4OWZhMDAyNCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlbW8tYWRtaW4ifQ.wy8aku1jvUBSH3_F7Uo3p4r2Iud60kNuRa5lgxM0I8bdBg96fagzZa95jXfbfmsfVPmXv6iRYWeAaJemjMnj0h-SaqyR4yXwoKpP-MtFF_Yq3wGrbbt3_FQ-alT-ejaI0M--AYOGVJmSh8aU2TFWUTmj3hwEhOGmmwmc7XrUPd_EUGfKKpl5swEWl0p92PczlV4yQPeZ3eu_iCvQExifsYxAU7bfqhesOkaffXSACCkBWBk3VzYHlHzHQg1XOgeWA4Hq03QiMPODF3Fx1MQ9LEotaP8y7PJYQeOeqyDQbg9kGtodrbrBTy-CZKQeBSP8JRKvGWNwc4OF4xLRy51nKw --server=https://c115-e.eu-de.containers.cloud.ibm.com:30205",
        "",
        " ",
        " ",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : LOGIN -  🚀 Demo Apps] *************************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 Demo Apps] *****************************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "Demo Apps - Details",
        "**********************************************************************************************************************************",
        "    RobotShop:",
        "        APP URL:           http://web-robot-shop.xxx-0000.eu-de.containers.appdomain.cloud/",
        "",
        "    Kubetoy:",
        "        APP URL:           http:///",
        " ",
        " ",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : LOGIN -  🚀 LDAP Connection] *******************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 LDAP Connection] ***********************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "LDAP Connection Details",
        "**********************************************************************************************************************************",
        "    OPENLDAP:",
        "        URL:      http://openldap-admin-default.xxx-0000.eu-de.containers.appdomain.cloud",
        "        User:     cn=admin,dc=ibm,dc=com",
        "        Password: P4ssw0rd!",
        " ",
        " ",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - Turbonomic] ***************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - Istio] ********************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - AWX] **********************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : LOGIN -  🚀 ADDONS - AWX] **********************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 ADDONS - AWX] **************************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "AWX Connection Details",
        "**********************************************************************************************************************************",
        "    AWX:",
        "                🌏 URL:      https://awx-awx.xxx-0000.eu-de.containers.appdomain.cloud",
        "                🧑 User:     admin",
        "                🔐 Password: aaaaa",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - ManageIQ] *****************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - Humio] ********************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - Rook/Ceph] ****************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : CHECK -  🔎 ADDONS - ELK] **********************************************************************************************************************************************
ok: [localhost]

TASK [90_aiops-logins : LOGIN -  🚀 Flink Task Manager] ****************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 Flink Task Manager] ********************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "Flink Task Manager",
        "**********************************************************************************************************************************",
        "    Flink Task Manager:",
        "        APP URL:           https://job-manager-cp4waiops.xxx-0000.eu-de.containers.appdomain.cloud/",
        "",
        "        In Chrome: if you get blocked just type thisisunsafe and it will continue (you don't get any visual feedback when typing!)",
        " ",
        " ",
        " ",
        " "
    ]
}

TASK [90_aiops-logins : LOGIN -  🚀 Vault] *****************************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 Vault] *********************************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "Vault",
        "**********************************************************************************************************************************",
        "                🌏 URL:      https://ibm-vault-deploy-vault-route-cp4waiops.xxx-0000.eu-de.containers.appdomain.cloud",
        "                🔐 Token:    s.FFJ65T23WRoghBnniKUmU2G7"
    ]
}

TASK [90_aiops-logins : LOGIN -  🚀 Service Now Connection] ************************************************************************************************************************************
changed: [localhost]

TASK [90_aiops-logins : LOGIN -          🔐 Service Now Connection] ****************************************************************************************************************************
ok: [localhost] => {
    "output_string.stdout_lines": [
        "**********************************************************************************************************************************",
        "Service Now Connection Details",
        "**********************************************************************************************************************************",
        "            📥 Login SNOW Dev Portal (if you have to wake the dev instance):",
        "    ",
        "                🌏 URL:                   https://developer.servicenow.com/dev.do",
        "                🧑 User:                  demo@mydemo.center",
        "                🔐 Password:              P4ssw0rd!IBM",
        "",
        "",
        "            📥  Login SNOW Instance::",
        "",
        "                🌏 URL:                   https://dev56805.service-now.com",
        "                🧑 User ID:               abraham.lincoln             (if you followed the demo install instructions)",
        "                🔐 Password:              P4ssw0rd!                   (if you followed the demo install instructions)",
        "                🔐 Encrypted Password:    g4W3L7/eFsUjV0eMncBkbg==    (if you followed the demo install instructions)",
        "",
        "",
        "            📥 INTEGRATION SNOW-->CP4WAIOPS:",
        "    ",
        "                🌏 URL:                   https://cpd-cp4waiops.xxx-0000.eu-de.containers.appdomain.cloud    (URL for IBM Watson AIOps connection)",
        "                📛 Instance Name:         aimanager",
        "                🧑 User:                  admin",
        "                🔐 Password:              0LncD8QoGl4V5zjS984NX9EjxTqGCtYK",
        " ",
        " ",
        " ",
        " "
    ]
}

PLAY RECAP *************************************************************************************************************************************************************************************
localhost                  : ok=109  changed=71   unreachable=0    failed=0    skipped=33   rescued=0    ignored=2

/Users/nhirt/DOCUMENTS_SYNC/4_PROJECTS/1_CLOUDPAKS/2_INSTALL/2_AIOPS/aiops-3.2-ansible
    -----------------------------------------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------------------------------
    🚀 AI Manager Login
    -----------------------------------------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------------------------------

      📥 AI Manager

                🌏 URL:      https://

                🧑 User:     admin
                🔐 Password: abcd

             
```

