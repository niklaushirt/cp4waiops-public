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
# Installing UBUNTU prerequisites for CP4WAIOPS 3.1
#
# VWatson AIOps v3.3
#
# ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"


echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AI OPS v3.3 - Install UBUNTU Prerequisites"
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "


echo "🚀 Installing prerequisites"
echo ""

    echo "   🧰 Install Tools"
    echo ""  


sudo apt-get update 

sudo apt-get install -y
sudo apt-get install -y openssh-server
sudo apt-get install -y ansible
sudo apt-get install -y kafkacat
sudo apt-get install -y python3-pip
sudo apt-get install -y npm
sudo apt-get install -y jq
sudo apt-get install -y curl

# Install Openshift Client
curl -L https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp-dev-preview/pre-release/openshift-client-linux.tar.gz  -o openshift-client-linux.tar.gz
tar xfvz openshift-client-linux.tar.gz 
sudo mv oc /usr/local/bin
sudo mv kubectl /usr/local/bin/ 
sudo rm openshift-client-linux.tar.gz

# Install cloudctl
curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz 
tar xfvz cloudctl-linux-amd64.tar.gz 
sudo mv cloudctl-linux-amd64 /usr/local/bin/cloudctl 
sudo rm cloudctl-linux-amd64.tar.gz


# Install stuff
ansible-galaxy collection install community.kubernetes:1.2.1
ansible-galaxy collection install kubernetes.core:2.2.3
ansible-galaxy collection install cloud.common
pip3 install openshift pyyaml kubernetes 
sudo npm install elasticdump -g
pip3 install slack-cleaner2




# Install k9s
wget https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_arm64.tar.gz 
tar xfzv k9s_Linux_arm64.tar.gz  
sudo mv k9s /usr/local/bin && rm LICENSE 
sudo rm README.md 
sudo rm k9s_Linux_arm64.tar.gz 



        echo "      📥 Install Ansible"
        sudo apt-get install -y ansible

        echo "      📥 Install Ansible Kubernetes"
        ansible-galaxy collection install community.kubernetes:1.2.1
        ansible-galaxy collection install kubernetes.core:2.2.3
        pip install openshift pyyaml kubernetes 

        echo "      📥 Install kafkacat"
        sudo apt-get install -y kafkacat
        
        echo "      📥 Install npm"
        sudo apt-get install -y npm
        
        echo "      📥 Install elasticdump"
        sudo npm install elasticdump -g
        
        echo "      📥 Install jq"
        sudo apt-get install -y jq

        echo "      📥 Install cloudctl"
        curl -L https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz -o cloudctl-linux-amd64.tar.gz
        tar xfvz cloudctl-linux-amd64.tar.gz
        sudo mv cloudctl-linux-amd64 /usr/local/bin/cloudctl
        rm cloudctl-linux-amd64.tar.gz

        
    echo ""  
    echo "" 
    echo ""  
    echo "   🧰 Install OpenShift Client"
    echo ""  
        wget https://github.com/openshift/okd/releases/download/4.7.0-0.okd-2021-07-03-190901/openshift-client-linux-4.7.0-0.okd-2021-07-03-190901.tar.gz -O oc.tar.gz
        tar xfzv oc.tar.gz
        sudo mv oc /usr/local/bin
        sudo mv kubectl /usr/local/bin
        rm oc.tar.gz
        rm README.md

    echo ""  
    echo ""  
    echo ""  
    echo "   🧰 Install K9s"
    echo ""  
        wget https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
        tar xfzv k9s_Linux_x86_64.tar.gz
        sudo mv k9s /usr/local/bin
        rm LICENSE
        rm README.md

        

echo ""  
echo ""  
echo "Installing prerequisites DONE..."



echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo " ✅ Prerequisites Installed"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------------------------------------------------------"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"



