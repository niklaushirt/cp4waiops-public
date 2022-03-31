---------------------------------------------------------------
# 22 Manually train the models
---------------------------------------------------------------



Only do this if you don't want to use 🐥 Easy Install

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

![](./pics/training1.png)

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

![](./pics/training2.png)

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

![](./pics/training3.png)

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

![](./pics/training4.png)

* Click on `Deploy vXYZ`


             
```

