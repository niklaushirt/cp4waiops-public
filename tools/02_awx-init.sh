#!/bin/bash
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - Configure AWX"
echo "*****************************************************************************************************************************"
echo "  "

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


echo ""
echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🛠️  Initialisation"

export AWX_ROUTE=$(oc get route -n awx awx -o jsonpath={.spec.host})
export ADMIN_USER=admin
export ADMIN_PASSWORD=$(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)

export OCP_URL=https://c108-e.eu-gb.containers.cloud.ibm.com:30553
export OCP_TOKEN=CHANGE-ME

export AWX_REPO=$INSTALL_REPO
export RUNNER_IMAGE=niklaushirt/cp4waiops-awx:0.1.3


echo "       ✅  Done"


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🔎  Parameters"
echo "        🧔 ADMIN_USER:                $ADMIN_USER"
echo "        🔐 ADMIN_PASSWORD:            $ADMIN_PASSWORD"
echo "        🌏 AWX_ROUTE:                 $AWX_ROUTE"
echo ""     
echo "        📥 SHOW_TOOLS:                $SHOW_TOOLS"
echo "        📥 SHOW_ADDONS:               $SHOW_ADDONS"
echo "        📥 SHOW_CONFIG:               $SHOW_CONFIG"
echo "        📥 SHOW_DEBUG:                $SHOW_DEBUG"
echo ""
echo ""
echo ""

echo "        🔐 ENTITLED_REGISTRY_KEY:     $ENTITLED_REGISTRY_KEY"


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Execution Environment"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS Execution Environment",
    "description": "CP4WAIOPS Execution Environment",
    "organization": null,
    "image": "'$RUNNER_IMAGE'",
    "credential": null,
    "pull": "missing"
}')

if [[ $result =~ " already exists" ]];
then
    export EXENV_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Execution Environment")|.id')
    echo "        Already exists with ID:$EXENV_ID"
else
    echo "        Execution Environment created: "$(echo $result|jq ".created")
    export EXENV_ID=$(echo $result|jq ".id")
fi 


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Project"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS ANSIBLE INSTALLER",
    "description": "CP4WAIOPS ANSIBLE INSTALLER",
    "local_path": "",
    "scm_type": "git",
    "scm_url": "'$AWX_REPO'",
    "scm_branch": "",
    "scm_refspec": "",
    "scm_clean": false,
    "scm_track_submodules": false,
    "scm_delete_on_update": false,
    "credential": null,
    "timeout": 0,
    "organization": 1,
    "scm_update_on_launch": false,
    "scm_update_cache_timeout": 0,
    "allow_override": false,
    "default_environment": null
}')

if [[ $result =~ " already exists" ]];
then
    export PROJECT_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS ANSIBLE INSTALLER")|.id')
    echo "        Already exists with ID:$PROJECT_ID"
else
    echo "        Project created: "$(echo $result|jq ".created")
    export PROJECT_ID=$(echo $result|jq ".id")
fi



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create AWX Inventory"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "CP4WAIOPS Install",
    "description": "CP4WAIOPS Install",
    "organization": 1,
    "project": '$PROJECT_ID',
    "kind": "",
    "host_filter": null,
    "variables": "---\nOCP_LOGIN: false\nOCP_URL: '$OCP_URL'\nOCP_TOKEN: '$OCP_TOKEN'\n#ENTITLED_REGISTRY_KEY: '$ENTITLED_REGISTRY_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    export INVENTORY_ID=$(curl -X "GET" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq -c '.results[]| select( .name == "CP4WAIOPS Install")|.id')
    echo "        Already exists with ID:$INVENTORY_ID"
else
    echo "        Inventory created: "$(echo $result|tr -d '\n'|jq ".created")
    export INVENTORY_ID=$(echo $result|tr -d '\n'|jq ".id")
    echo ""
    echo "   ------------------------------------------------------------------------------------------------------------------------------"
    echo "   🕦  Waiting 15s"
    sleep 15
fi


echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   ✅  RPOJECT Parameters"
echo "        🧔 EXECUTION_ENV:             $EXENV_ID"
echo "        🔐 INVENTORY_ID:              $INVENTORY_ID"
echo "        🌏 PROJECT_ID:                $PROJECT_ID"
echo ""



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager Demo"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "00_Install CP4WAIOPS AI Manager Demo",
    "description": "Install CP4WAIOPS AI Manager Demo - ALL STEPS - See here https://github.ibm.com/NIKH/aiops-install-ansible-33",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/00_aimanager-install-all.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "ENTITLED_REGISTRY_KEY: '$ENTITLED_REGISTRY_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS AI Manager - Vanilla"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "01_Install CP4WAIOPS AI Manager - Vanilla",
    "description": "Install CP4WAIOPS AI Manager Vanilla Install - See here https://github.ibm.com/NIKH/aiops-install-ansible-33",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/01_aimanager-base-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "ENTITLED_REGISTRY_KEY: '$ENTITLED_REGISTRY_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Event Manager - Vanilla"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "02_Install CP4WAIOPS Event Manager - Vanilla",
    "description": "02_Install CP4WAIOPS Event Manager Vanilla Install",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/04_eventmanager-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nENTITLED_REGISTRY_KEY: '$ENTITLED_REGISTRY_KEY'"
}
')
if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Install CP4WAIOPS Infrastructure Management"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "03_Install CP4WAIOPS Infrastructure Management",
    "description": "03_Install CP4WAIOPS Infrastructure Management",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/05_inframanagement-install.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID',
    "ask_variables_on_launch": true,
    "extra_vars": "---\nENTITLED_REGISTRY_KEY: '$ENTITLED_REGISTRY_KEY'"
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 



echo ""
echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Create Job: Get CP4WAIOPS Logins"
export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
-H 'content-type: application/json' \
-d $'{
    "name": "10_Get CP4WAIOPS Logins",
    "description": "10_Get CP4WAIOPS Logins",
    "job_type": "run",
    "inventory": '$INVENTORY_ID',
    "project": '$PROJECT_ID',
    "playbook": "ansible/90_get-all-logins.yaml",
    "scm_branch": "",
    "extra_vars": "",
    "execution_environment": '$EXENV_ID'
}
')

if [[ $result =~ " already exists" ]];
then
    echo "        Already exists."
else
    echo "        Job created: "$(echo $result|jq ".created")
fi 




if [[ $SHOW_TOOLS == "true" ]];
then


            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install Rook Ceph"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "70_Install Rook Ceph",
                "description": "Install Rook Ceph",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/14_install-rook-ceph.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 


            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install CP4WAIOPS Demo UI"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "71_Install CP4WAIOPS Demo UI",
                "description": "Install CP4WAIOPS Demo UI",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/16_aimanager-install-demo-ui.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 



            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install CP4WAIOPS Toolbox"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "72_Install CP4WAIOPS Toolbox",
                "description": "Install CP4WAIOPS Toolbox",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/17_aimanager-install-toolbox.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 

                        echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install LDAP"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "73_Install LDAP",
                "description": "Install LDAP and register users. This is usually already done by the AI Manager Installation.",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/11_install-ldap-server.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 



            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install RobotShop"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "74_Install RobotShop",
                "description": "Install RobotShop. This is usually already done by the AI Manager Installation.",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/13_install-robot-shop.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 
fi




if [[ $SHOW_ADDONS == "true" ]];
then
            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install Turbonomic"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "20_Install Turbonomic",
                "description": "Install Turbonomic",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/20_addons-install-turbonomic.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 


            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install Humio"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "21_Install Humio",
                "description": "Install Humio",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/21_addons-install-humio.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 


            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install ELK"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "22_Install ELK",
                "description": "Install ELK",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/22_addons-install-elk-ocp.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 

            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Install AWX"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "23_Install AWX",
                "description": "Install AWX",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/23_addons-install-awx.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 

            # echo ""
            # echo "   ------------------------------------------------------------------------------------------------------------------------------"
            # echo "   🚀  Create Job: Install ManageIQ"
            # export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            # -H 'content-type: application/json' \
            # -d $'{
            #     "name": "24_Install ManageIQ",
            #     "description": "Install ManageIQ",
            #     "job_type": "run",
            #     "inventory": '$INVENTORY_ID',
            #     "project": '$PROJECT_ID',
            #     "playbook": "ansible/24_install-manageiq.yaml",
            #     "scm_branch": "",
            #     "extra_vars": "",
            #     "execution_environment": '$EXENV_ID'
            # }
            # ')

            # if [[ $result =~ " already exists" ]];
            # then
            #     echo "        Already exists."
            # else
            #     echo "        Job created: "$(echo $result|jq ".created")
            # fi 


            # echo ""
            # echo "   ------------------------------------------------------------------------------------------------------------------------------"
            # echo "   🚀  Create Job: Install ServiceMesh"
            # export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            # -H 'content-type: application/json' \
            # -d $'{
            #     "name": "29_Install ServiceMesh",
            #     "description": "Install ServiceMesh",
            #     "job_type": "run",
            #     "inventory": '$INVENTORY_ID',
            #     "project": '$PROJECT_ID',
            #     "playbook": "ansible/29_addons-install-servicemesh.yaml",
            #     "scm_branch": "",
            #     "extra_vars": "",
            #     "execution_environment": '$EXENV_ID'
            # }
            # ')

            # if [[ $result =~ " already exists" ]];
            # then
            #     echo "        Already exists."
            # else
            #     echo "        Job created: "$(echo $result|jq ".created")
            # fi 

fi



if [[ $SHOW_CONFIG == "true" ]];
then

            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Load Topology and Runbooks for AI Manager"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "80_Load Topology and Runbooks for AI Manager",
                "description": "Load Topology and Runbooks for AI Manager",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/02_aimanager-topology_runbooks.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 



            # echo ""
            # echo "   ------------------------------------------------------------------------------------------------------------------------------"
            # echo "   🚀  Create Job: Topology Load for Event Manager"
            # export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            # -H 'content-type: application/json' \
            # -d $'{
            #     "name": "82_Topology Load for Event Manager",
            #     "description": "Topology Load for Event Manager",
            #     "job_type": "run",
            #     "inventory": '$INVENTORY_ID',
            #     "project": '$PROJECT_ID',
            #     "playbook": "ansible/80_load-topology-event.yaml",
            #     "scm_branch": "",
            #     "extra_vars": "",
            #     "execution_environment": '$EXENV_ID'
            # }
            # ')

            # if [[ $result =~ " already exists" ]];
            # then
            #     echo "        Already exists."
            # else
            #     echo "        Job created: "$(echo $result|jq ".created")
            # fi 




            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Train All Models"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "81_Train All Models",
                "description": "Train All Models, takes about 5-7 Minutes",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/03_aimanager-training.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')
            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 

fi








if [[ $SHOW_DEBUG == "true" ]];
then

            echo ""
            echo "   ------------------------------------------------------------------------------------------------------------------------------"
            echo "   🚀  Create Job: Debug Patch"
            export result=$(curl -X "POST" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure \
            -H 'content-type: application/json' \
            -d $'{
                "name": "90_Debug Patch",
                "description": "Debug Patch",
                "job_type": "run",
                "inventory": '$INVENTORY_ID',
                "project": '$PROJECT_ID',
                "playbook": "ansible/91_aimanager-debug-patches.yaml",
                "scm_branch": "",
                "extra_vars": "",
                "execution_environment": '$EXENV_ID'
            }
            ')

            if [[ $result =~ " already exists" ]];
            then
                echo "        Already exists."
            else
                echo "        Job created: "$(echo $result|jq ".created")
            fi 



fi



echo "    "
echo "    "
echo "    "
echo "    "
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " 🔎 AWX Installed Content"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Projects"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/projects/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Inventories"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/inventories/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Execution Environments"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/execution_environments/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    📥 AWX Job Templates"
curl -X "GET" -s "https://$AWX_ROUTE/api/v2/job_templates/" -u "$ADMIN_USER:$ADMIN_PASSWORD" --insecure|jq ".results[].name"| sed 's/^/         /'
echo "    "
echo "    "
echo "    "


echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " 🚀 AWX Access"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo " -----------------------------------------------------------------------------------------------------------------------------------------------"
echo "    "
echo "     📥 AWX :"
echo ""
echo "         🌏 URL:      https://$AWX_ROUTE"
echo "         🧑 User:     admin"
echo "         🔐 Password: $(oc -n awx get secret awx-admin-password -o jsonpath='{.data.password}' | base64 --decode && echo)"
echo "    "
echo "    "


echo "*****************************************************************************************************************************"
echo " ✅ DONE"
echo "*****************************************************************************************************************************"

while true
do
    sleep 60000                           
done

