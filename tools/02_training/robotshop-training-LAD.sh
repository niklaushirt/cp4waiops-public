
export APP_NAME=robot-shop
export INDEX_TYPE=logs


#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOT EDIT BELOW
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



if [[  $WAIOPS_NAMESPACE =~ "" ]]; then
    # Get Namespace from Cluster 
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🔬 Getting Installation Namespace"
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
    echo "       ✅ AI Manager:         OK - $WAIOPS_NAMESPACE"
else
    echo "       ✅ AI Manager:         OK - $WAIOPS_NAMESPACE"
fi




if [[ $ROUTE =~ "ai-platform-api" ]]; then
    echo "       ✅ OK - Route:         OK"
else
    echo "       🛠️  Creating Route"
    oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None
    export ROUTE=$(oc get route -n cp4waiops ai-platform-api  -o jsonpath={.spec.host})
    echo "        Route: $ROUTE"
    echo ""
fi
echo ""



echo "  ***************************************************************************************************************************************************"
echo "   🛠️  Turn off RSA - Log Anomaly Statistical Baseline"
export FILE_NAME=deactivate-analysis-RSA.graphql
./tools/02_training/scripts/execute-graphql.sh



echo "  ***************************************************************************************************************************************************"
echo "   🛠️  Create Data Set: Log Anomaly Detection"
echo "     "	
echo "      📥 Launch Query for file: create-dataset-LAD.graphql"	
echo "     "
QUERY="$(cat ./tools/02_training/training-definitions/create-dataset-LAD.graphql)"
JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
export result=$(curl -XPOST "https://$ROUTE/graphql" -k -s -H 'Content-Type: application/json' -d "${JSON_QUERY}")
export DATA_SET_ID=$(echo $result| jq -r ".data.createDataSet.dataSetId")
echo "      🔎 Result: "
echo "       "$result|jq ".data" | sed 's/^/          /'
echo "     "	
echo "     "	



echo "  ***************************************************************************************************************************************************"
echo "   🛠️  Create Analysis Definiton: Log Anomaly Detection"
echo "     "	
echo "      📥 Launch Query for file: create-analysis-LAD.graphql"	
echo "     "
QUERY_TMPL="$(cat ./tools/02_training/training-definitions/create-analysis-LAD.graphql)"
QUERY=$(echo $QUERY_TMPL | sed "s/<DATA_SET_ID>/$DATA_SET_ID/g")
JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
export result=$(curl -XPOST "https://$ROUTE/graphql" -k -s -H 'Content-Type: application/json' -d "${JSON_QUERY}")
echo "      🔎 Result: "
echo "       "$result|jq ".data" | sed 's/^/          /'
echo "     "	
echo "     "	



echo "  ***************************************************************************************************************************************************"
echo "   🛠️  Run Analysis: Log Anomaly Detection"
export FILE_NAME=run-analysis-LAD.graphql
./tools/02_training/scripts/execute-graphql.sh


