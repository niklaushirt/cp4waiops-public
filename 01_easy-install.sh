#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS v3.3 - CP4WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"

export SHOW_MORE="false"
export WAIOPS_PODS_MIN=115
export DOC_URL="https://github.ibm.com/NIKH/aiops-install-ansible-33#2-ai-manager-installation"

# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# Do Not Modify Below
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"

export COLOR_SUPPORT=$(tput colors)
if [[ $COLOR_SUPPORT -gt 250 ]]; then
      source ./tools/99_colors.sh
fi

clear

echo "${BYellow}*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  🐥 CloudPak for Watson AIOps v3.3 - Easy Install"
echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "${NC}  "
echo "  "





while getopts "t:v:r:hc:" opt
do
    case "$opt" in
        t ) INPUT_TOKEN="$OPTARG" ;;
        v ) VERBOSE="$OPTARG" ;;
        r ) REPLACE_INDEX="$OPTARG" ;;
        h ) HELP_USAGE=true ;;

    esac
done


    
if [[ $HELP_USAGE ]];
then
    echo " USAGE: $0 [-t <REGISTRY_TOKEN>] [-v true] [-r true]"
    echo "  "
    echo "     -t  Provide registry pull token              <REGISTRY_TOKEN> "
    echo "     -v  Verbose mode                             true/false"
    echo "     -r  Replace indexes if they already exist    true/false"

    exit 1
fi

echo "${Purple}"

if [[ $INPUT_TOKEN == "" ]];
then
    echo " 🔐  Token                              ${Red} Not Provided (will be asked during installation)${Purple}"
else
    echo " 🔐  Token                               ${Green}Provided${Purple}"
    export ENTITLED_REGISTRY_KEY=$INPUT_TOKEN
fi


if [[ $VERBOSE ]];
then
    echo " ✅  Verbose Mode                        On"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=true
    export VERBOSE="-v"
else
    echo " ❎  Verbose Mode                        Off          (enable it by appending '-v true')"
    export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
    export VERBOSE=""
fi


if [[ $REPLACE_INDEX ]];
then
    echo " ❌  Replace existing Indexes            ${BRed}On ❗         (existing training indexes will be replaced/reloaded)${Purple}"
    export SILENT_SKIP=false
else
    echo " ✅  Replace existing Indexes            ${Green}Off${Purple}          (default - enable it by appending '-r true')"
    export SILENT_SKIP=true

fi
echo ""
echo ""
echo "${NC}"

export TEMP_PATH=~/aiops-install


CHECK_RUNBOOKS () {
      ZEN_API_HOST=$(oc get route --ignore-not-found -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      if [[ ! $ZEN_API_HOST == "" ]]; then

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

            ZEN_TOKEN=$(echo "${ZEN_LOGIN_RESPONSE}" | jq -r .token)
            export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})

            export result=$(curl -X "GET" -s -k "https://$ROUTE/aiops/api/story-manager/rba/v1/runbooks" \
                  -H "Authorization: bearer $ZEN_TOKEN" \
                  -H 'Content-Type: application/json; charset=utf-8')
            export RUNBOOKS_EXISTS=$(echo "$result"| jq ".[]._runbookId"|wc -l|tr -d ' ')
      else
            export TRAINING_EXISTS=0
      fi
}


CHECK_TRAINING () {
    export ROUTE=""
    export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

      ZEN_API_HOST=$(oc get route --ignore-not-found -n $WAIOPS_NAMESPACE cpd -o jsonpath='{.spec.host}')
      if [[ ! $ZEN_API_HOST == "" ]]; then

            oc create route passthrough ai-platform-api -n $WAIOPS_NAMESPACE  --service=aimanager-aio-ai-platform-api-server --port=4000 --insecure-policy=Redirect --wildcard-policy=None>/dev/null 2>/dev/null
            export ROUTE=$(oc get route -n $WAIOPS_NAMESPACE ai-platform-api  -o jsonpath={.spec.host})



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



      QUERY="$(cat ./tools/02_training/training-definitions/checkLAD.graphql)"
      JSON_QUERY=$(echo "${QUERY}" | jq -sR '{"operationName": null, "variables": {}, "query": .}')
      export result=$(curl -XPOST -k -s "https://$ROUTE/graphql" -k \
      -H 'Accept-Encoding: gzip, deflate, br'  \
      -H 'Content-Type: application/json'  \
      -H 'Accept: application/json'  \
      -H 'Connection: keep-alive'  \
      -H 'DNT: 1'  \
      -H "Origin: $ROUTE"  \
      -H "authorization: Bearer $ZEN_TOKEN"  \
      --data-binary "${JSON_QUERY}"  \
      --compressed)
      export TRAINING_DEFINITIONS=$(echo $result| jq ".data.getTrainingDefinitions")
      if [[  $TRAINING_DEFINITIONS == "[]" ]]; then
            export TRAINING_EXISTS=false
      else
            export TRAINING_EXISTS=true
      fi
    else
            export TRAINING_EXISTS=false
    fi
}


echo ""
echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------"
echo " 🐥  Initializing..." 
echo "--------------------------------------------------------------------------------------------"
echo ""

printf "${BYellow}\r  🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Checking Command Line Tools                                  "

if [ ! -x "$(command -v oc)" ]; then
      echo "❌ Openshift Client not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v jq)" ]; then
      echo "❌ jq not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v ansible-playbook)" ]; then
      echo "❌ Ansible not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v cloudctl)" ]; then
      echo "❌ cloudctl not installed."
      echo "   🚀 Install prerequisites with ./ansible/scripts/02-prerequisites-mac.sh or ./ansible/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi

printf "\r  🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster Status                                       "
export CLUSTER_STATUS=$(oc status | grep "In project")
printf "\r  🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting Cluster User                                         "

export CLUSTER_WHOAMI=$(oc whoami)

if [[ ! $CLUSTER_STATUS =~ "In project" ]]; then
      echo "❌ You are not logged into a Openshift Cluster."
      echo "❌ Aborting...."
      exit 1
else
      printf "${NC}\r ✅ $CLUSTER_STATUS as user $CLUSTER_WHOAMI\n\n${BYellow}"

fi


printf "  🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting AI Manager Namespace                                    "
export WAIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')
export WAIOPS_PODS=$(oc get pods -n $WAIOPS_NAMESPACE |grep -v Completed|grep -v "0/"|wc -l|tr -d ' ')

if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
      printf "\r  🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 -  Getting Event Manager Namespace                              "
      export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting RobotShop Status                                      "
      export RS_NAMESPACE=$(oc get ns robot-shop  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Check if models have been trained                             "
      CHECK_TRAINING
      printf "\r  🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚 - Check if Runbooks exist                                       "
      CHECK_RUNBOOKS
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚 - Getting Turbonomic Status                                     "
      export TURBO_NAMESPACE=$(oc get ns turbonomic  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚 - Getting AWX Status                                            "
      export AWX_NAMESPACE=$(oc get ns awx  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚 - Getting LDAP Status                                           "
      export LDAP_NAMESPACE=$(oc get po -n default --ignore-not-found| grep ldap |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚 - Getting Aiops Toolbox Status                                  "
      export TOOLBOX_READY=$(oc get po -n default|grep cp4waiops-tools| grep 1/1 |awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚 - Getting ELK Status                                            "
      export ELK_NAMESPACE=$(oc get ns openshift-logging  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚 - Getting Istio Status                                          "
      export ISTIO_NAMESPACE=$(oc get ns istio-system  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚 - Getting Humio Status                                          "
      export HUMIO_NAMESPACE=$(oc get ns humio-logging  --ignore-not-found|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣 - GettingDEMO UI Status                                          "
      export DEMOUI_READY=$(oc get pods -n $WAIOPS_NAMESPACE |grep waiops-demo-ui-python|awk '{print$1}')
      printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥 - Done ✅                                                        "
fi




# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# Patch IAF Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
openTheUrl () {
      if [[ ! $OPEN_URL == "" ]]; then
            if [ -x "$(command -v open)" ]; then
                  open $OPEN_URL
            else 
                  if [ -x "$(command -v firefox)" ]; then
                        firefox $OPEN_URL
                  else 
                        if [ -x "$(command -v google-chrome)" ]; then
                              google-chrome $OPEN_URL
                        else
                              echo "No executable to open URL $OPEN_URL. Skipping..."
                        fi
                  fi
            fi
    else
      echo "URL undefined"
    fi
}

menu_EASY_03 () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Finalize Install for AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
            cd ansible
            ansible-playbook 03_aimanager-finalize-install.yaml
            cd -
      else
            echo "❗ I told you that this is not yet available. Wait for step 01 to complete."
      fi
}

menu_EASY_02 () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Post Install for AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
            cd ansible
            ansible-playbook 02_aimanager-post-install.yaml
            cd -
            echo "*****************************************************************************************************************************"
            echo "*****************************************************************************************************************************"
            echo "*****************************************************************************************************************************"
            echo "*****************************************************************************************************************************"
            echo "  "
            echo "  ✅ Ai Manager Post Installation done"
            echo "  "
            echo "  🐥 Please restart Easy Installer"
            echo "  🐥 And launch Option 03"
            echo "  "
            echo "*****************************************************************************************************************************"
            echo "*****************************************************************************************************************************"

            exit 0
      else
            echo "❗ I told you that this is not yet available. Wait for step 01 to complete."
      fi

}

menu_EASY_ALL () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install complete Demo Environment for AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS AI Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi
      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""

      # Install
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo ""

            cd ansible
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 00_aimanager-install-all.yaml
            cd -




      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi

      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "  "
      echo "  ✅ Complete Demo Environment for AI Manager Installation done"
      echo "  "
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"


}



menu_EASY_01 () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Base Install for AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS AI Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi
      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""

      # Install
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo ""

            cd ansible
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 01_aimanager-base-install.yaml
            cd -




      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi

      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"
      echo "  "
      echo "  ✅ Ai Manager Base Installation done"
      echo "  "
      echo "  🐥 Please restart Easy Installer"
      echo "  🐥 And launch Option 02"
      echo "  "
      echo "*****************************************************************************************************************************"
      echo "*****************************************************************************************************************************"

      exit 0

}


menu_INSTALL_AIMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS AI Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi
      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""

      # Install
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
           
            echo ""
            echo "   ✅ Ok, continuing without demo content..."
            echo ""
            echo ""
            echo "--------------------------------------------------------------------------------------------"
            echo " ❗  Installation can take up to one hour!" 
            echo "--------------------------------------------------------------------------------------------"

            echo ""
            cd ansible
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 10_install-cp4waiops_ai_manager_only
            cd -
         
            echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
            echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
            echo "    🚀 AI Manager Login"
            echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
            echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
            echo "    "
            echo "      📥 AI Manager"
            echo ""
            echo "                🌏 URL:      https://$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})"
            echo ""
            echo "                🧑 User:     $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)"
            echo "                🔐 Password: $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)"
            echo "     "


      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}




menu_INSTALL_EVTMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Event Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      # Check if already installed
      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "⚠️  CP4WAIOPS Event Manager seems to be installed already"

            read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo ""
                  echo "   ✅ Ok, continuing..."
                  echo ""
            else
                  echo ""
                  echo "    ❌  Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  return
            fi

      fi

      #Get Pull Token
      if [[ $ENTITLED_REGISTRY_KEY == "" ]];
      then
            echo ""
            echo ""
            echo "  Enter CP4WAIOPS Pull token: "
            read TOKEN
      else
            TOKEN=$ENTITLED_REGISTRY_KEY
      fi

      # Install
      echo ""
      echo "  🔐 You have provided the following Token:"
      echo "    "$TOKEN
      echo ""
      read -p "  Are you sure that this is correct❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""
            echo "--------------------------------------------------------------------------------------------"
            echo " ❗  Installation can take up to 40 mins!" 
            echo "--------------------------------------------------------------------------------------------"
            echo ""
            cd ansible
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 04_eventmanager-install.yaml
            cd -

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi


}




menuDEMO_OPEN () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Demo UI - Details"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      appURL=$(oc get routes -n $WAIOPS_NAMESPACE waiops-demo-ui-python  -o jsonpath="{['spec']['host']}")|| true
      appToken=$(oc get cm -n $WAIOPS_NAMESPACE demo-ui-python-config -o jsonpath='{.data.TOKEN}')
      echo "            📥 Demo UI:"   
      echo "    " 
      echo "                🌏 URL:           http://$appURL/"
      echo "                🔐 Token:         $appToken"
      echo ""
      echo ""
      export OPEN_URL="http://$appURL"
      openTheUrl
}
     


menuAWX_OPENDOC () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Opening Documentation "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      export OPEN_URL=$DOC_URL
      openTheUrl
}




menuAWX_OPENAWX () {
      export AWX_ROUTE="https://"$(oc get route -n awx awx -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 AWX "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 AWX :"
      echo ""
      echo "                🌏 URL:      $AWX_ROUTE"
      echo "                🧑 User:     admin"
      echo "                🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
      echo "    "
      echo "    "
      export OPEN_URL=$AWX_ROUTE
      openTheUrl

}



menuAIMANAGER_OPEN () {
      export ROUTE="https://"$(oc get route -n $WAIOPS_NAMESPACE cpd -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 AI Manager"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "      📥 AI Manager"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo ""
      echo "                🧑 User:     $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 --decode && echo)"
      echo "                🔐 Password: $(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode)"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}



menuEVENTMANAGER_OPEN () {
      export ROUTE="https://"$(oc get route -n $EVTMGR_NAMESPACE  evtmanager-ibm-hdm-common-ui -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Event Manager (Netcool Operations Insight)"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "      📥 Event Manager"
      echo ""
      echo "            🌏 URL:      $ROUTE"
      echo ""
      echo "            🧑 User:     smadmin"
      echo "            🔐 Password: $(oc get secret -n $EVTMGR_NAMESPACE  evtmanager-was-secret -o jsonpath='{.data.WAS_PASSWORD}'| base64 --decode && echo)"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENELK () {
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 ELK "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      token=$(oc sa get-token cluster-logging-operator -n openshift-logging)
      routeES=`oc get route elasticsearch -o jsonpath={.spec.host} -n openshift-logging`
      routeKIBANA=`oc get route kibana -o jsonpath={.spec.host} -n openshift-logging`
      echo "      "
      echo "            📥 ELK:"
      echo "      "
      echo "               🌏 ELK service URL             : https://$routeES/app*"
      echo "               🔐 Authentication type         : Token"
      echo "               🔐 Token                       : $token"
      echo "      "
      echo "               🌏 Kibana URL                  : https://$routeKIBANA"
      echo "               🚪 Kibana port                 : 443"
      export OPEN_URL=https://$routeKIBANA
      openTheUrl

}


menuAWX_OPENISTIO () {
      export KIALI_ROUTE="https://"$(oc get route -n istio-system kiali -o jsonpath={.spec.host})
      export RS_ROUTE="http://"$(oc get route -n istio-system istio-ingressgateway -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 ServiceMesh/ISTIO "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 ServiceMesh:"
      echo ""
      echo "                🌏 RobotShop:     $RS_ROUTE"
      echo "                🌏 Kiali:         $KIALI_ROUTE"
      echo "                🌏 Jaeger:        https://$(oc get route -n istio-system jaeger -o jsonpath={.spec.host})"
      echo "                🌏 Grafana:       https://$(oc get route -n istio-system grafana -o jsonpath={.spec.host})"
      echo "    "
      echo "    "
      echo "          In the begining all traffic is routed to ratings-test"
      echo "            You can modify the routing by executing:"
      echo "              All Traffic to test:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-100-0.yaml"
      echo "              Traffic split 50-50:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-50-50.yaml"
      echo "              All Traffic to prod:    oc apply -n robot-shop -f ./ansible/templates/demo_apps/robotshop/istio/ratings-0-100.yaml"
      echo "    "
      echo "    "
      echo "    "
      export OPEN_URL=$KIALI_ROUTE
      openTheUrl    
      export OPEN_URL=$RS_ROUTE
      openTheUrl

}

menuAWX_OPENTURBO () {
      export ROUTE="https://"$(oc get route -n turbonomic api -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Turbonomic Dashboard "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 Turbonomic Dashboard :"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     administrator"
      echo "                🔐 Password: As set at init step"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENHUMIO () {
      export ROUTE="https://"$(oc get route -n humio-logging humio -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 HUMIO "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 HUMIO:"
      echo ""
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     developer"
      echo "                🔐 Password: P4ssw0rd!"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}


menuAWX_OPENLDAP () {
      export ROUTE="http://"$(oc get route -n default openldap-admin -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 LDAP "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    " 
      echo "            📥 OPENLDAP:"
      echo "    " 
      echo "                🌏 URL:      $ROUTE"
      echo "                🧑 User:     cn=admin,dc=ibm,dc=com"
      echo "                🔐 Password: P4ssw0rd!"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl
}





menuAWX_OPENRS () {
      export ROUTE="http://"$(oc get routes -n robot-shop web  -o jsonpath="{['spec']['host']}")
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 RobotShop "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "    "
      export OPEN_URL=$ROUTE
      openTheUrl

}



menuINSTALL_AWX_EASY () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Start AWX Easy Install" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      oc apply -f ./ansible/templates/awx/awx-create-easy-installer.yaml

     echo ""

      echo "   ------------------------------------------------------------------------------------------------------------------------------"
      echo "   🕦  Wait for AWX pods ready"
      while [ `oc get pods -n awx| grep postgres|grep 1/1 | wc -l| tr -d ' '` -lt 1 ]
      do
            echo "        AWX pods not ready yet. Waiting 15 seconds"
            sleep 15
      done
      echo "       ✅  OK: AWX pods ready"

      export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
      export AWX_URL=$(echo "https://$AWX_ROUTE")


      echo ""
      echo "   ------------------------------------------------------------------------------------------------------------------------------"
      echo "   🕦  Wait for AWX being ready"
      while : ; do
            READY=$(curl -s $AWX_URL|grep "Application is not available")
            if [[  $READY  =~ "Application is not available" ]]; then
                  echo "        AWX not ready yet. Waiting 15 seconds"
                  sleep 30
            else
                  break
            fi
      done
      echo "       ✅  OK: AWX ready"


      export AWX_ROUTE="https://"$(oc get route -n awx awx -o jsonpath={.spec.host})
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 AWX "
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "            📥 AWX :"
      echo ""
      echo "                🌏 URL:      $AWX_ROUTE"
      echo "                🧑 User:     admin"
      echo "                🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
      echo "    "
      echo "    "

      open $AWX_ROUTE
}



menuTRAIN_AIOPSDEMO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Start CP4WAIOPS Demo Training (skip)" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
     ansible-playbook ./ansible/85_aimanager-training-all-steps.yaml
}




menuLOAD_TOPOLOGY () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for AI Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      ansible-playbook ./ansible/80_aimanager-create-topology-all-steps.yaml
}

menuLOAD_TOPOLOGYNOI () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for Event Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      ./tools/05_topology/eventmanager/create-merge-rules.sh
      ./tools/05_topology/eventmanager/create-merge-topology-robotshop.sh

}





menuDEBUG_PATCH () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Launch Debug Patches" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      read -p "   Are you sure you want to continue❓ [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo ""
            echo "   ✅ Ok, continuing..."
            echo ""
      else
            echo ""
            echo "    ❌  Aborting"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
            return
      fi


      cd ansible
      ansible-playbook 91_aimanager-debug-patches.yaml
      cd -

}

menu_INSTALL_TOOLBOX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Toolbox Pod" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 17_aimanager-install-toolbox.yaml
      cd -

}


menu_INSTALL_AIOPSDEMO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Demo UI" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      oc delete job -n $WAIOPS_NAMESPACE demo-ui-create-config>/dev/null 2>/dev/null
      oc delete cm -n $WAIOPS_NAMESPACE demo-ui-config>/dev/null 2>/dev/null
      oc delete deployment -n $WAIOPS_NAMESPACE ibm-aiops-demo-ui>/dev/null 2>/dev/null
      cd ansible
      ansible-playbook 16_aimanager-install-demo-ui.yaml
      cd -

      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Demo UI - Details"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      appURL=$(oc get routes -n $WAIOPS_NAMESPACE waiops-demo-ui-python  -o jsonpath="{['spec']['host']}")|| true
      appToken=$(oc get cm -n $WAIOPS_NAMESPACE demo-ui-python-config -o jsonpath='{.data.TOKEN}')
      echo "            📥 Demo UI:"   
      echo "    " 
      echo "                🌏 URL:           http://$appURL/"
      echo "                🔐 Token:         $appToken"
      echo ""
      echo ""
      open "http://"$appURL

}


menu_INSTALL_ROBOTSHOP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install RobotShop" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 13_install-robot-shop.yaml
      cd -
}


menu_INSTALL_LDAP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install LDAP" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 11_install-ldap-server.yaml
      cd -
}

menu_INSTALL_TURBO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Turbonomic" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 20_addons-install-turbonomic.yaml
      cd -
}


menu_INSTALL_AWX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install AWX" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 23_addons-install-awx.yaml
      cd -
}


menu_INSTALL_GITOPS () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install GitOps/ArgoCD" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 24_addons-install-gitops.yaml
      cd -
}


menu_INSTALL_ELK () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Logging" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 22_addons-install-elk-ocp.yaml
      cd -
}



menu_INSTALL_ISTIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Mesh" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 29_addons-install-servicemesh.yaml
      cd -
}



menu_INSTALL_HUMIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Humio" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ ! $HUMIO_NAMESPACE == "" ]]; then
            echo "❗⚠️ Humio seems to be installed already"

            read -p " ❗❓ Are you sure you want to continue? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo "   ✅ Ok, continuing..."
                  echo ""
                  echo ""

            else
                  echo "    ❌ Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit 1
            fi

      fi

      echo ""
      echo ""
      echo "  Enter Humio License: "
      read TOKEN
      echo ""
      echo "You have entered the following license:"
      echo $TOKEN
      echo ""
      read -p " ❗❓ Are you sure that this is correct? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""

cd ansible
ansible-playbook -e HUMIO_LICENSE_KEY=$TOKEN 21_addons-install-humio.yaml
cd -
            

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}



incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------"
}

until [ "$selection" = "0" ]; do
  
clear

echo "${BYellow}*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "     __________  __ ___       _____    ________            "
echo "     / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo "    / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "   / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "   \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                             /_/            "
echo ""
echo "   🐥 CloudPak for Watson AIOPs - EASY INSTALL"
echo ""
echo "*****************************************************************************************************************************"
echo ""
echo "${Purple}"
if [[ $ENTITLED_REGISTRY_KEY == "" ]];
then
echo "      🔐 Image Pull Token:           ${Red}Not Provided (will be asked during installation)${Purple}"
else
echo "      🔐 Image Pull Token:           ${Green}Provided${Purple}"
fi

echo "      🌏 Namespace:                  ${Green}$WAIOPS_NAMESPACE${Purple}"	
echo "      💾 Skip Data Load if exists:   ${Green}$SILENT_SKIP${Purple}"	
echo "      🔎 Verbose Mode:               ${Green}$ANSIBLE_DISPLAY_SKIPPED_HOSTS${Purple}"
echo "${NC}"
echo "${BYellow}   "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "${NC}"

      echo "  🐥 ${UYellow}CP4WAIOPS - Complete Install${NC}"


      if [[ $WAIOPS_PODS -lt $WAIOPS_PODS_MIN ]]; then
            echo "     🚀  ${BYellow}00  - Step 1: Install AI Manager Demo${NC}   ${Green}<-- Start here${NC}        - Install Complete AI Manager Demo"
      else
            echo "     ✅  ${DGreen}00  - Step 1: Install AI Manager Demo${NC}                         - Already installed "
      fi

      echo "  "
      echo "  "
      echo "  🐥 ${UYellow}CP4WAIOPS - Guided Install${NC}"

      if [[ $WAIOPS_PODS -lt $WAIOPS_PODS_MIN ]]; then
            echo "     🚀  ${BYellow}01  - Step 1: Install Base AI Manager${NC}                                      - Install Vanilla AI Manager"
      else
            echo "     ✅  ${DGreen}01  - Step 1: Install Base AI Manager${NC}                         - Already installed "
      fi

      if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
            if [[ $TRAINING_EXISTS == "false" ]]; then
                  echo "     🚀  ${BYellow}02  - Step 2: Post Install Base AI Manager${NC}                    - Post Install Steps for AI Manager"
            else
                  echo "     ✅  ${DGreen}02  - Step 2: Post Install Base AI Manager${NC}                    - Already installed (Models trained: $TRAINING_EXISTS)"
            fi
      else
            echo "         ${BBlack}02  - Step 2: Post Install Base AI Manager${NC}                    - Not yet available. Wait for step 01 to complete."
      fi

      if [[ $WAIOPS_PODS -gt $WAIOPS_PODS_MIN ]]; then
            if [[ $RUNBOOKS_EXISTS == "0" ]]; then
                  echo "     🚀  ${BYellow}03  - Step 3: Finalize Install Base AI Manager${NC}                - Finalize Install for AI Manager"
            else
                  echo "     ✅ ${DGreen} 03  - Step 3: Finalize Install Base AI Manager${NC}                - Already installed (Runbooks created: $CHECK_RUNBOOKS)"
            fi
      else
            echo "         ${BBlack}03  - Step 3: Finalize Install Base AI Manager${NC}                - Not yet available. Wait for step 02 to complete."

      fi

      echo "         09  - Open Documentation                                      - Open the AI Manager installation Documentation"


      echo "  "
      echo "  "
      echo "  "



      echo "  "
      echo "  🌏 ${UYellow}Access Information${NC}"
      echo "         81  - Get logins                                              - Get logins for all installed components"
      echo "         82  - Write logins to file                                    - Write logins for all installed components to file LOGIN.txt"
      echo "  "

      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "         90  - Open AI Manager                                         - Open AI Manager"
      fi

      if [[ ! $DEMOUI_READY == "" ]]; then
            echo "         91  - Open AI Manager Demo                                    - Open AI Manager Incident Demo UI"
      fi

      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "         92  - Open Event Manager                                      - Open Event Manager"
      fi

      if [[ ! $TURBO_NAMESPACE == "" ]]; then
            echo "         93  - Open Turbonomic                                         - Open Turbonomic Instance"
      fi

      if [[ ! $ELK_NAMESPACE == "" ]]; then
            echo "         94  - Open ELK                                                - Open ELK Instance"
      fi

      if [[ ! $HUMIO_NAMESPACE == "" ]]; then
            echo "         95  - Open Humio                                              - Open Humio Instance"
      fi

      if [[ ! $ISTIO_NAMESPACE == "" ]]; then
            echo "         96  - Open Istio                                              - Open ServcieMesh/Istio Kiali Instance"
      fi

      if [[ ! $LDAP_NAMESPACE == "" ]]; then
            echo "         97  - Open OpenLDAP                                           - Open OpenLDAP Instance"
      fi

      if [[ ! $RS_NAMESPACE == "" ]]; then
            echo "         98  - Open RobotShop                                          - Open RobotShop Demo Application"
      fi

      if [[ ! $AWX_NAMESPACE == "" ]]; then
            echo "         99  - Open AWX                                                - Open AWX Instance (Open Source Ansible Tower)"
      fi
      echo "  "
      echo "  "


      if [[ $SHOW_MORE == "true" ]]; then


            echo "  🐥 ${UYellow}CP4WAIOPS - Base Install Only (without any demo content)${NC}"
            if [[ $WAIOPS_NAMESPACE == "" ]]; then
                  echo "         11  - Install AI Manager                                      - Install CP4WAIOPS AI Manager Component Only"
            else
                  echo "     ✅  11  - Install AI Manager                                      - Already installed "
            fi

            if [[ $EVTMGR_NAMESPACE == "" ]]; then
                  echo "         12  - Install Event Manager                                   - Install CP4WAIOPS Event Manager Component Only"
            else
                  echo "     ✅  12  - Install Event Manager                                   - Already installed "
            fi



            echo "  "
            echo "  🐥 ${UYellow}CP4WAIOPS Addons${NC}"
            if [[  $DEMOUI_READY == "" ]]; then
                  echo "         17  - Install CP4WAIOPS Demo Application                      - Install CP4WAIOPS Demo Application"
            else
                  echo "     ✅  17  - Install CP4WAIOPS Demo Application                      - Already installed "
            fi

            if [[  $TOOLBOX_READY == "" ]]; then
                  echo "         18  - Install CP4WAIOPS Toolbox                               - Install Toolbox pod with all important tools (oc, kubectl, kafkacat, ...)"
            else
                  echo "     ✅  18  - Install CP4WAIOPS Toolbox                               - Already installed "
            fi



            if [[  $LDAP_NAMESPACE == "" ]]; then
                  echo "         32  - Install OpenLdap                                        - Install OpenLDAP for CP4WAIOPS (should be installed by option 11)"
            else
                  echo "     ✅  32  - Install OpenLdap                                        - Already installed "
            fi

            if [[  $RS_NAMESPACE == "" ]]; then
                  echo "         33  - Install RobotShop                                       - Install RobotShop for CP4WAIOPS (should be installed by option 11)"
            else
                  echo "     ✅  33  - Install RobotShop                                       - Already installed  "
            fi




            echo "  "
            echo "  🐥 ${UYellow}Third Party Solutions${NC}"
            if [[ $TURBO_NAMESPACE == "" ]]; then
                  echo "         21  - Install Turbonomic                                      - Install Turbonomic (needs a separate license)"
            else
                  echo "     ✅  21  - Install Turbonomic                                      - Already installed "
            fi

            if [[  $HUMIO_NAMESPACE == "" ]]; then
                  echo "         22  - Install Humio                                           - Install Humio (needs a separate license)"
            else
                  echo "     ✅  22  - Install Humio                                           - Already installed "
            fi


            if [[  $AWX_NAMESPACE == "" ]]; then
                  echo "         23  - Install AWX                                             - Install AWX (open source Ansible Tower)"
            else
                  echo "     ✅  23  - Install AWX                                             - Already installed "
            fi

            if [[  $ISTIO_NAMESPACE == "" ]]; then
                  echo "         24  - Install OpenShift Mesh                                  - Install OpenShift Mesh (Istio)"
                  else
                  echo "     ✅  24  - Install OpenShift Mesh                                  - Already installed "
                  fi



            if [[  $ELK_NAMESPACE == "" ]]; then
                  echo "         25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
                  else
                  echo "     ✅  25  - Install OpenShift Logging                               - Already installed "
                  fi






                  #       echo "    	25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
            echo "  "
            echo "  🐥 ${UYellow}Demo Configuration${NC}"
            echo "         51  - AI Manager Topology                                     - Create RobotShop Topology for AI Manager (must create Observers before - documentation 3.2)"
            if [[  $TRAINING_EXISTS == "" ]]; then
                  echo "         55  - Train RobotShop Models                                  - Loads training data, creates definitions and launches training (Models trained: $TRAINING_EXISTS)"
            else
                  echo "     ✅  55  - Train RobotShop Models                                  - Models already trained: $TRAINING_EXISTS)"
            fi



            echo "  "
            echo "  🐥 ${UYellow}Ansible AWX - WAIOPS Installer${NC}"
            if [[  $AWX_NAMESPACE == "" ]]; then
                  echo "         61  - Install AWX and Jobs                                    - Create AWX and preload Jobs for a complete installation"
            else
                  echo "     ✅  61  - Install AWX and Jobs                                    - Already installed "
            fi


            echo "  "
            echo "  🐥 ${UYellow}Prerequisites Install${NC}"
            echo "         71  - Install Prerequisites Mac                               - Install Prerequisites for Mac"
            echo "         72  - Install Prerequisites Ubuntu                            - Install Prerequisites for Ubuntu"




            # echo "  "
            # echo "  🦟 ${UYellow}Debug${NC}"
            # echo "         999  - Debug Patch                                             - Patches if your AI Manager install is hanging"
            # echo "  "
      else 
            echo "  "
            echo "  "
            echo "      🛠️   ${NC}m  -  Show more options${NC}                                      - Show advanced options"

      fi





  echo "      "
  echo "      ❌  ${Red}0  -  Exit${NC}"
  echo ""
  echo ""
  echo "  ${BGreen}Enter selection: ${NC}"
  read selection
  echo ""
  case $selection in
      09 ) clear ; menuAWX_OPENDOC  ;;
      00 ) clear ; menu_EASY_ALL  ;;
      01 ) clear ; menu_EASY_01  ;;
      02 ) clear ; menu_EASY_02  ;;
      03 ) clear ; menu_EASY_03  ;;

      11 ) clear ; menu_INSTALL_AIMGR  ;;
      12 ) clear ; menu_INSTALL_EVTMGR  ;;

      21 ) clear ; menu_INSTALL_TURBO  ;;
      22 ) clear ; menu_INSTALL_HUMIO  ;;
      23 ) clear ; menu_INSTALL_AWX  ;;
      24 ) clear ; menu_INSTALL_ISTIO  ;;
      25 ) clear ; menu_INSTALL_ELK  ;;
      25 ) clear ; menu_INSTALL_GITOPS  ;;

      17 ) clear ; menu_INSTALL_AIOPSDEMO  ;;
      18 ) clear ; menu_INSTALL_TOOLBOX  ;;
      32 ) clear ; menu_INSTALL_LDAP  ;;
      33 ) clear ; menu_INSTALL_ROBOTSHOP  ;;



      51 ) clear ; menuLOAD_TOPOLOGY  ;;
      52 ) clear ; menuLOAD_TOPOLOGYNOI  ;;
      55 ) clear ; menuTRAIN_AIOPSDEMO  ;;

      61 ) clear ; menuINSTALL_AWX_EASY  ;;

      71 ) clear ; ./10_install_prerequisites_mac.sh  ;;
      72 ) clear ; ./11_install_prerequisites_ubuntu.sh  ;;

      81 ) clear ; ./tools/20_get_logins.sh  ;;
      82 ) clear ; ./tools/20_get_logins.sh > LOGINS.txt  ;;

      90 ) clear ; menuAIMANAGER_OPEN  ;;
      91 ) clear ; menuDEMO_OPEN  ;;
      92 ) clear ; menuEVENTMANAGER_OPEN  ;;
      93 ) clear ; menuAWX_OPENTURBO  ;;
      94 ) clear ; menuAWX_OPENELK  ;;
      95 ) clear ; menuAWX_OPENHUMIO  ;;
      96 ) clear ; menuAWX_OPENISTIO  ;;
      97 ) clear ; menuAWX_OPENLDAP  ;;
      98 ) clear ; menuAWX_OPENRS  ;;
      99 ) clear ; menuAWX_OPENAWX  ;;

      999 ) clear ; menuDEBUG_PATCH  ;;

      m ) clear ; SHOW_MORE=true  ;;



      0 ) clear ; exit ;;
      * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


