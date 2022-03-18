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
#  CP4WAIOPS 3.2 - CP4WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
clear

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  🐥 CloudPak for Watson AIOps 3.2 - Easy Install"
echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
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



if [[ $INPUT_TOKEN == "" ]];
then
    echo " 🔐  Token                               Not Provided (will be asked during installation)"
else
    echo " 🔐  Token                               Provided"
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
    echo " ❌  Replace existing Indexes            On ❗         (existing training indexes will be replaced/reloaded)"
    export SILENT_SKIP=false
else
    echo " ✅  Replace existing Indexes            Off          (default - enable it by appending '-r true')"
    export SILENT_SKIP=true

fi
echo ""
echo ""


export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"

echo ""
echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------------------------"
echo " 🐥  Initializing..." 
echo "--------------------------------------------------------------------------------------------"
echo ""

printf "\r  🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Checking Command Line Tools                                  "

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
      printf "\r ✅ $CLUSTER_STATUS as user $CLUSTER_WHOAMI\n\n"

fi


printf "  🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚🥚 - Getting AI Manager Namespace                                    "
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
printf "\r  🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚🥚 -  Getting Event Manager Namespace                              "
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚🥚 - Getting RobotShop Status                                      "
export RS_NAMESPACE=$(oc get ns robot-shop  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚🥚 - Getting Turbonomic Status                                     "
export TURBO_NAMESPACE=$(oc get ns turbonomic  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚🥚 - Getting AWX Status                                            "
export AWX_NAMESPACE=$(oc get ns awx  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚🥚 - Getting LDAP Status                                           "
export LDAP_NAMESPACE=$(oc get po -n default --ignore-not-found| grep ldap |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚🥚 - Getting Aiops Toolbox Status                                       "
export TOOLBOX_READY=$(oc get po -n default|grep cp4waiops-tools| grep 1/1 |awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚🥚 - Getting ELK Status                                            "
export ELK_NAMESPACE=$(oc get ns openshift-logging  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚🥚 - Getting Istio Status                                          "
export ISTIO_NAMESPACE=$(oc get ns istio-system  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣🥚 - Getting Humio Status                                          "
export HUMIO_NAMESPACE=$(oc get ns humio-logging  --ignore-not-found|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐣 - GettingDEMO UI Status                                          "
export DEMOUI_READY=$(oc get pods -n $WAIOPS_NAMESPACE |grep ibm-aiops-demo-ui|awk '{print$1}')
printf "\r  🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥 - Done ✅                                                        "





# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# Patch IAF Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
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
            read -p "  Do you want to install demo content (highly recommended - OpenLdap and RobotShop)❓ [Y,n] " DO_COMM
            if [[ $DO_COMM == "n" ||  $DO_COMM == "N" ]]; then
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
            else
                  echo ""
                  echo "   ✅ Ok, continuing with demo content..."
                  echo ""
                  echo ""

                  echo ""

                  cd ansible
                  ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 10_install-cp4waiops_ai_manager_only_with_demo.yaml
                  cd -

            fi



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
            ansible-playbook -e ENTITLED_REGISTRY_KEY=$TOKEN 11_install-cp4waiops_event_manager.yaml
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
      appURL=$(oc get routes -n $WAIOPS_NAMESPACE cp4waiops-demo-ui  -o jsonpath="{['spec']['host']}")|| true
      appToken=$(oc get cm -n cp4waiops demo-ui-config -o jsonpath='{.data.TOKEN}')
      echo "            📥 Demo UI:"   
      echo "    " 
      echo "                🌏 URL:           http://$appURL/"
      echo "                🔐 Token:         $appToken"
      echo ""
      echo ""
      open "http://"$appURL


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

      open $AWX_ROUTE

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

      open  $ROUTE

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


      open  $ROUTE

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

      open  https://$routeKIBANA

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

      open  $KIALI_ROUTE      
      open  $RS_ROUTE

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

      open  $ROUTE

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

      open  $ROUTE

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

      open  $ROUTE

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


      open  $ROUTE

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
     ./55_train-robotshop.sh
}




menuLOAD_TOPOLOGY () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for AI Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

     ./51_load_robotshop_topology_aimanager.sh
}

menuLOAD_TOPOLOGYNOI () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Load RobotShop Topology for Event Manager Demo" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

     ./52_load_robotshop_topology_eventmanager.sh
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
      ansible-playbook 91_aiops-debug-patches.yaml
      cd -

}

menu_INSTALL_TOOLBOX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Toolbox Pod" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 17_aiops-toolbox.yaml
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
      ansible-playbook 18_aiops-demo-ui.yaml
      cd -

      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Demo UI - Details"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      appURL=$(oc get routes -n $WAIOPS_NAMESPACE cp4waiops-demo-ui  -o jsonpath="{['spec']['host']}")|| true
      appToken=$(oc get cm -n cp4waiops demo-ui-config -o jsonpath='{.data.TOKEN}')
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
      ansible-playbook 18_install-robot-shop.yaml
      cd -
}


menu_INSTALL_LDAP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install LDAP" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 18_install-ldap.yaml
      cd -
}

menu_INSTALL_TURBO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Turbonomic" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 20_install-turbonomic.yaml
      cd -
}


menu_INSTALL_AWX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install AWX" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 23_install-awx.yaml
      cd -
}




menu_INSTALL_ELK () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Logging" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 22_install-elk-ocp.yaml
      cd -
}



menu_INSTALL_ISTIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Mesh" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      cd ansible
      ansible-playbook 29_install-servicemesh.yaml
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
ansible-playbook -e HUMIO_LICENSE_KEY=$TOKEN 21_install-humio.yaml
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

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "      __________  __ ___       _____    ________            "
echo "     / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo "    / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "   / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "   \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                             /_/            "
echo ""
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - EASY INSTALL"
echo "*****************************************************************************************************************************"
echo ""

if [[ $ENTITLED_REGISTRY_KEY == "" ]];
then
echo "      🔐 Image Pull Token:          Not Provided (will be asked during installation)"
else
echo "      🔐 Image Pull Token:          Provided"
fi

echo "      🌏 Namespace:                 $WAIOPS_NAMESPACE"	
echo "      💾 Skip Data Load if exists:  $SILENT_SKIP"	
echo "      🔎 Verbose Mode:              $ANSIBLE_DISPLAY_SKIPPED_HOSTS"


echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "








      echo "  🐥 CP4WAIOPS - Base Install"
      if [[ $WAIOPS_NAMESPACE == "" ]]; then
            echo "         11  - Install AI Manager                                      - Install CP4WAIOPS AI Manager Component"
      else
            echo "         11 ✅ Install AI Manager                                      - Already installed "
      fi

      if [[ $EVTMGR_NAMESPACE == "" ]]; then
            echo "         12  - Install Event Manager                                   - Install CP4WAIOPS Event Manager Component"
      else
            echo "         12 ✅ Install Event Manager                                   - Already installed "
      fi



      echo "  "
      echo "  🐥 CP4WAIOPS Addons"
      if [[  $DEMOUI_READY == "" ]]; then
            echo "         17  - Install CP4WAIOPS Demo Application                      - Install CP4WAIOPS Demo Application"
      else
            echo "         17 ✅ Install CP4WAIOPS Demo Application                      - Already installed "
      fi

      if [[  $TOOLBOX_READY == "" ]]; then
            echo "         18  - Install CP4WAIOPS Toolbox                               - Install Toolbox pod with all important tools (oc, kubectl, kafkacat, ...)"
      else
            echo "         18 ✅ Install CP4WAIOPS Toolbox                               - Already installed "
      fi



      if [[  $LDAP_NAMESPACE == "" ]]; then
            echo "         32  - Install OpenLdap                                        - Install OpenLDAP for CP4WAIOPS (should be installed by option 11)"
      else
            echo "         32 ✅ Install OpenLdap                                        - Already installed "
      fi

      if [[  $RS_NAMESPACE == "" ]]; then
            echo "         33  - Install RobotShop                                       - Install RobotShop for CP4WAIOPS (should be installed by option 11)"
      else
            echo "         33 ✅ Install RobotShop                                       - Already installed  "
      fi




      echo "  "
      echo "  🐥 Third Party Solutions"
      if [[ $TURBO_NAMESPACE == "" ]]; then
            echo "         21  - Install Turbonomic                                      - Install Turbonomic (needs a separate license)"
      else
            echo "         21 ✅ Install Turbonomic                                      - Already installed "
      fi

      if [[  $HUMIO_NAMESPACE == "" ]]; then
            echo "         22  - Install Humio                                           - Install Humio (needs a separate license)"
      else
            echo "         22 ✅ Install Humio                                           - Already installed "
      fi


      if [[  $AWX_NAMESPACE == "" ]]; then
            echo "         23  - Install AWX                                             - Install AWX (open source Ansible Tower)"
      else
            echo "         23 ✅ Install AWX                                             - Already installed "
      fi

      if [[  $ISTIO_NAMESPACE == "" ]]; then
            echo "         24  - Install OpenShift Mesh                                  - Install OpenShift Mesh (Istio)"
            else
            echo "         24 ✅ Install OpenShift Mesh                                  - Already installed "
            fi



      if [[  $ELK_NAMESPACE == "" ]]; then
            echo "         25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
            else
            echo "         25 ✅ Install OpenShift Logging                               - Already installed "
            fi





            #       echo "    	25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
      echo "  "
      echo "  🐥 Demo Configuration"
      echo "         51  - AI Manager Topology                                     - Create RobotShop Topology for AI Manager (must create Observers before - documentation 4.)"
      echo "         52  - Event Manager Topology                                  - Create RobotShop Topology for Event Manager (must create Observers before - documentation 11.1)"
      echo "         55  - Train RobotShop Models                                  - Loads training data, creates definitions and launches training (skip if index exists: $SILENT_SKIP)"
      
      echo "  "
      echo "  🐥 Ansible AWX"
      if [[  $AWX_NAMESPACE == "" ]]; then
            echo "         61  - Install AWX and Jobs                                    - Create AWX and preload Jobs for a complete installation"
      else
            echo "         61 ✅ Install AWX and Jobs                                    - Already installed "
      fi


      echo "  "
      echo "  🐥 Prerequisites Install"
      echo "         71  - Install Prerequisites Mac                               - Install Prerequisites for Mac"
      echo "         72  - Install Prerequisites Ubuntu                            - Install Prerequisites for Ubuntu"


      echo "  "
      echo "  🌏 Access Information"
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
      echo "  🦟 Debug"
      echo "         999  - Debug Patch                                             - Patches if your AI Manager install is hanging"
      echo "  "






  echo "      "
echo "      ❌  0  -  Exit"
  echo ""
  echo ""
  echo "  Enter selection: "
  read selection
  echo ""
  case $selection in
    11 ) clear ; menu_INSTALL_AIMGR  ;;
    12 ) clear ; menu_INSTALL_EVTMGR  ;;

    21 ) clear ; menu_INSTALL_TURBO  ;;
    22 ) clear ; menu_INSTALL_HUMIO  ;;
    23 ) clear ; menu_INSTALL_AWX  ;;
    24 ) clear ; menu_INSTALL_ISTIO  ;;
    25 ) clear ; menu_INSTALL_ELK  ;;

    17 ) clear ; menu_INSTALL_AIOPSDEMO  ;;
    18 ) clear ; menu_INSTALL_TOOLBOX  ;;
    32 ) clear ; menu_INSTALL_LDAP  ;;
    33 ) clear ; menu_INSTALL_ROBOTSHOP  ;;



    51 ) clear ; menuLOAD_TOPOLOGY  ;;
    52 ) clear ; menuLOAD_TOPOLOGYNOI  ;;
    55 ) clear ; menuTRAIN_AIOPSDEMO  ;;

    61 ) clear ; menuINSTALL_AWX_EASY  ;;

    71 ) clear ; ./13_install_prerequisites_mac.sh  ;;
    72 ) clear ; ./14_install_prerequisites_ubuntu.sh  ;;

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


    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


