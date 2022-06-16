
INSTALL_POD=$(oc get po -n default|grep install|awk '{print$1}')

oc cp -n default ${INSTALL_POD}:/cp4waiops-public/installAIManager.log ./installAIManager.log
