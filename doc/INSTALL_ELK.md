-----------------------------------------------------------------------------------
# 14 Installing OCP ELK
---------------------------------------------------------------

## 14.1 Installing OCP ELK

Use Option 🐥`25` in Easy Install to install a `ELK` instance

## 14.2 Manually installing OCP ELK

You can easily install ELK into the same cluster as CP4WAIOPS.


1. Launch

	```bash
	ansible-playbook ./ansible/22_addons-install-elk-ocp.yaml
	```
2. Wait for the pods to come up
3. Open Kibana


<div style="page-break-after: always;"></div>
