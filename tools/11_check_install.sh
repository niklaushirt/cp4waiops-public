#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS v3.3 - Debug WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AIOps v3.3 - Check WAIOPS Installation"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "


export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

function check_array_crd(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep "AGE" || true) 

            if  ([[ ! $ELEMENT_OK =~ "AGE" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}

function check_array(){

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check $CHECK_NAME"
      echo "--------------------------------------------------------------------------------------------"

      for ELEMENT in ${CHECK_ARRAY[@]}; do
            ELEMENT_NAME=${ELEMENT##*/}
            ELEMENT_TYPE=${ELEMENT%%/*}
       echo "   Check $ELEMENT_NAME ($ELEMENT_TYPE) ..."

            ELEMENT_OK=$(oc get $ELEMENT -n $WAIOPS_NAMESPACE | grep $ELEMENT_NAME || true) 

            if  ([[ ! $ELEMENT_OK =~ "$ELEMENT_NAME" ]]); 
            then 
                  echo "      ⭕ $ELEMENT not present"; 
                  echo ""
            else
                  echo "      ✅ OK: $ELEMENT"; 

            fi
      done
      export CHECK_NAME=""
}


export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')


CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


echo "  Initializing......"
























































#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Examining CP4WAIOPS AI Manager Configuration...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "🔎 Initializing"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"

      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   🛠️  Get Route"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None>/dev/null 2>/dev/null
      export ROUTE=$(oc get route -n cp4waiops ai-platform-api  -o jsonpath={.spec.host})
      echo "       Route: $ROUTE"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "🔎 Trained Models"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"


      echo "       🛠️  Getting ZEN Token"
     
      ZEN_API_HOST=$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      ZEN_LOGIN_URL="https://${ZEN_API_HOST}/v1/preauth/signin"
      LOGIN_USER=admin
      LOGIN_PASSWORD="$(oc get secret admin-user-details -n $WAIOPS_NAMESPACE -o jsonpath='{ .data.initial_admin_password }' | base64 --decode)"

      ZEN_LOGIN_RESPONSE=$(
      curl -k \
      -H 'Content-Type: application/json' \
      -XPOST \
      "${ZEN_LOGIN_URL}" \
      -d '{
            "username": "'"${LOGIN_USER}"'",
            "password": "'"${LOGIN_PASSWORD}"'"
      }' 2> /dev/null
      )

      ZEN_LOGIN_MESSAGE=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .message)

      if [ "${ZEN_LOGIN_MESSAGE}" != "success" ]; then
            echo "Login failed: ${ZEN_LOGIN_MESSAGE}"
            exit 2
      fi

      ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)
      #echo "${ZEN_TOKEN}"
      echo "Sucessfully logged in" 
      echo ""




      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  LAD"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"query {\n    getTrainingDefinitions(algorithmName:Log_Anomaly_Detection) {\n      definitionName\n      algorithmName\n      version\n      deployedVersion\n      description\n      createdBy\n      modelDeploymentDate\n      trainedModels(latest: true) {\n        modelStatus\n        trainingStartTimestamp\n        trainingEndTimestamp\n        precheckTrainingDetails {\n          dataQuality\n          dataQualityDetails {\n            report\n            languageInfo {\n              language\n            }\n          }\n        }\n        postcheckTrainingDetails {\n          aiCoverage\n          overallModelQuality\n          modelsCreatedList {\n            modelId\n          }\n        }\n      }\n    }\n  }"}' --compressed)
      #echo $result| jq ".data.getTrainingDefinitions[].definitionName,.data.getTrainingDefinitions[].deployedVersion, .data.getTrainingDefinitions[].trainedModels.precheckTrainingDetails.dataQuality, .data.getTrainingDefinitions[].trainedModels.precheckTrainingDetails.dataQuality.dataQualityDetails.report, .data.getTrainingDefinitions[].trainedModels.postcheckTrainingDetails    , .data.getTrainingDefinitions[].postcheckTrainingDetails.aiCoverage"
      echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")
      echo "Data Quality:  "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].precheckTrainingDetails.dataQuality")" - " $(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].precheckTrainingDetails.dataQualityDetails.report[0]")
      echo "AI Coverage:   "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.aiCoverage")
      echo "Models:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.modelsCreatedList")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".modelDeploymentDate")
      #echo $result| jq 


      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  METRIC ANOMALIES"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"  query {\n    getTrainingDefinitions (algorithmName:Metric_Anomaly_Detection){\n      definitionName\n      algorithmName\n      description\n      version\n      deployedVersion\n      lastTraining\n      trainingSchedule {\n        frequency\n        repeat\n        noEndDate\n      }\n      trainedModels(latest: true) {\n        trainingStartTimestamp\n        trainingEndTimestamp\n        modelStatus\n        postcheckTrainingDetails {\n            aiCoverage\n          \n          }\n      }\n    }\n  }"}' --compressed)
      echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")
      echo "Schedule:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.frequency")" - " $(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.repeat")
      echo "Status:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].modelStatus")
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      #echo $result| jq 


      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  TEMPORAL GROUPING"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"query {\n    getTrainingDefinitions(algorithmName:Temporal_Grouping) {\n      definitionName\n      algorithmName\n      version\n      deployedVersion\n      description\n      createdBy\n      modelDeploymentDate\n      trainedModels(latest: true) {\n        modelStatus\n        trainingStartTimestamp\n        trainingEndTimestamp\n        postcheckTrainingDetails {\n          modelsCreatedList {\n            modelId\n          }\n        }\n      }\n    }\n  }"}' --compressed)
      echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")      
      echo "AI Coverage:   "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.modelsCreatedList")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".modelDeploymentDate")
      #echo $result| jq 


      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  SIMILAR INCIDENTS"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"  query {\n    getTrainingDefinitions (algorithmName:Similar_Incidents){\n      definitionName\n      algorithmName\n      description\n      version\n      deployedVersion\n      lastTraining\n      trainingSchedule {\n        frequency\n        repeat\n        noEndDate\n      }\n      trainedModels(latest: true) {\n        trainingStartTimestamp\n        trainingEndTimestamp\n        modelStatus\n        postcheckTrainingDetails {\n            aiCoverage\n          \n          }\n      }\n    }\n  }"}' --compressed)
            echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")      
      echo "Schedule:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.frequency")" - " $(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.repeat")
      echo "AI Coverage:   "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.aiCoverage")
      #echo $result| jq 


      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  CHANGE RISK"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"  query {\n    getTrainingDefinitions (algorithmName:Change_Risk){\n      definitionName\n      algorithmName\n      description\n      version\n      deployedVersion\n      lastTraining\n      trainingSchedule {\n        frequency\n        repeat\n        noEndDate\n      }\n      trainedModels(latest: true) {\n        trainingStartTimestamp\n        trainingEndTimestamp\n        modelStatus\n        postcheckTrainingDetails {\n            aiCoverage\n          \n          }\n      }\n    }\n  }"}' --compressed)
      echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")
      echo "Schedule:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.frequency")" - " $(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.repeat")
      echo "AI Coverage:   "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.aiCoverage")
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      #echo $result| jq 


      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "   📥  METRIC ANOMALIES"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo ""
      export result=$(curl "https://$ROUTE/graphql" -k -s -H "authorization: Bearer $ZEN_TOKEN" -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: https://ai-platform-api-cp4waiops.itzroks-270003bu3k-qd899z-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud' --data-binary '{"query":"  query {\n    getTrainingDefinitions (algorithmName:Metric_Anomaly_Detection){\n      definitionName\n      algorithmName\n      description\n      version\n      deployedVersion\n      lastTraining\n      trainingSchedule {\n        frequency\n        repeat\n        noEndDate\n      }\n      trainedModels(latest: true) {\n        trainingStartTimestamp\n        trainingEndTimestamp\n        modelStatus\n        postcheckTrainingDetails {\n            aiCoverage\n          \n          }\n      }\n    }\n  }"}' --compressed)
      echo "Name:          "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".definitionName")
      echo "Deployed:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".deployedVersion")
      echo "Latest:        "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".version")
      echo "Schedule:      "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.frequency")" - " $(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainingSchedule.repeat")
      echo "AI Coverage:   "$(echo $result| jq ".data.getTrainingDefinitions[]" | jq -r ".trainedModels[].postcheckTrainingDetails.aiCoverage")
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      #echo $result| jq 





    echo "--------------------------------------------------------------------------------------------------------------------------------"
    echo " 🚀  Examining CP4WAIOPS AI Manager Installation...." 
    echo "--------------------------------------------------------------------------------------------------------------------------------"

      echo ""
      echo ""
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      echo "🔎 Installed Openshift Operator Versions"
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"
      oc get -n $WAIOPS_NAMESPACE ClusterServiceVersion
      echo "------------------------------------------------------------------------------------------------------------------------------------------------------"


    

      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace ibm-common-services"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n ibm-common-services | grep -v "Completed" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $WAIOPS_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods not ready in Namespace $EVTMGR_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      oc get pods -n $EVTMGR_NAMESPACE | grep -v "Completed"| grep -v "Error" | grep "0/"


      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Pods with Image Pull Errors in Namespace $WAIOPS_NAMESPACE"
      echo "--------------------------------------------------------------------------------------------"

      export IMG_PULL_ERROR=$(oc get pods -n $WAIOPS_NAMESPACE | grep "ImagePull")

      if  ([[ ! $IMG_PULL_ERROR == "" ]]); 
      then 
            echo "      ⭕ There are Image Pull Errors:"; 
            echo "$IMG_PULL_ERROR"
            echo ""
            echo ""

            echo "      🔎 Check your Pull Secrets:"; 
            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

            echo ""
            echo ""
            echo "ibm-entitlement-key Pull Secret"
            oc get secret/ibm-entitlement-key -n $WAIOPS_NAMESPACE --template='{{index .data ".dockerconfigjson" | base64decode}}'

      else
            echo "      ✅ OK: All images can be pulled"; 
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check ZEN Operator"
      echo "--------------------------------------------------------------------------------------------"

      export ZEN_LOGS=$(oc logs --since=12h $(oc get po -n ibm-common-services|grep ibm-zen-operator|awk '{print$1}') -n ibm-common-services)
      export ZEN_ERRORS=$(echo $ZEN_LOGS|grep -i error)
      export ZEN_FAILED=$(echo $ZEN_LOGS|grep -i "failed=0")
      export ZEN_READY=$(echo $ZEN_LOGS|grep -i "ok=2")

      if  ([[ $ZEN_FAILED == "" ]]); 
      then 
            echo "      ⭕ Zen has errors"; 
            echo "$ZEN_ERRORS"
            echo ""
      else
            if  ([[ $ZEN_READY == "" ]]); 
            then 
                  echo "      ⭕ Zen Operator is still running"; 
                  echo ""
            else
                  echo "      ✅ OK: ZEN Operator has run successfully"; 
            fi
      fi




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Topology"
      echo "--------------------------------------------------------------------------------------------"

      CP4AIOPS_CHECK_LIST=(
      "aiops-topology-merge"
      "aiops-topology-status"
      "aiops-topology-topology")
      for ELEMENT in ${CP4AIOPS_CHECK_LIST[@]}; do
        echo "   Check $ELEMENT.."
            ELEMENT_OK=$(oc get pod -n $WAIOPS_NAMESPACE --ignore-not-found | grep $ELEMENT || true) 
            if  ([[ ! $ELEMENT_OK =~ "1/1" ]]); 
            then 
                  echo "      ⭕ Pod $ELEMENT not runing successfully"; 
                  echo ""
            else
                  echo "      ✅ OK: Pod $ELEMENT"; 

            fi

      done




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Routes"
      echo "--------------------------------------------------------------------------------------------"



      ROUTE_OK=$(oc get route job-manager -n $WAIOPS_NAMESPACE || true) 
      if  ([[ ! $ROUTE_OK =~ "job-manager" ]]); 
      then 
            echo "      ⭕ job-manager Route does not exist"; 
            echo "      ⭕ (You may want to run option: 12  - Recreate custom Routes)";  
            echo ""
      else
            echo "      ✅ OK: job-manager Route exists"; 
      fi

  
      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Clean-up Pods (if you get 'error: resource(s) were provided' you're good)"
      echo "--------------------------------------------------------------------------------------------"
      echo "      ❎ Clean-up errored Pods in $WAIOPS_NAMESPACE"
      oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep "Error"|grep "0/"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up stuck Pods in $WAIOPS_NAMESPACE"
      oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep -v "Completed"|grep "0/"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up evicted Pods in $WAIOPS_NAMESPACE"
      oc delete pod $(oc get po -n $WAIOPS_NAMESPACE|grep "Evicted"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found
      echo ""
      echo "      ❎ Clean-up evicted Pods in ibm-common-services"
      oc delete pod $(oc get po -n ibm-common-services|grep "Evicted"|awk '{print$1}') -n $WAIOPS_NAMESPACE --ignore-not-found




      echo ""
      echo ""
      echo "--------------------------------------------------------------------------------------------"
      echo "🔎 Check Error Events"
      echo "--------------------------------------------------------------------------------------------"
      oc get events -A|grep -v Normal