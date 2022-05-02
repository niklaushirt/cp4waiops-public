## 2.6 Install Event Manager 

![K8s CNI](./pics/install-evtmanager.png)

### 2.6.1 Start Event Manager Installation 

Use Option 🐥`12` in Easy Install to install a base `Event Manager` instance

or run:

```bash
ansible-playbook ./ansible/04_eventmanager-install.yaml -e ENTITLED_REGISTRY_KEY=<REGISTRY_TOKEN> 
```

### 2.6.2 Configure Event Manager 

There are some minimal configurations that you have to do to use the demo system and that are covered by the 🅱️ flow below:

###  🚀 Start here [EventManager Configuration](./CONF_EVENT_MANAGER.md)

<div style="page-break-after: always;"></div>

## 2.7 Installing additional components 

Select the options you want to install.

The ones marked with ✅ have already been detected as being present in the cluster.
![K8s CNI](./pics/tool4.png)


<div style="page-break-after: always;"></div>

## 19.3 Manually install EventManager (Optional)

Only do this if you don't want to use 🐥 Easy Install



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
ansible-playbook ./ansible/04_eventmanager-install.yaml -e ENTITLED_REGISTRY_KEY=<REGISTRY_TOKEN> 


Example:
ansible-playbook ./ansible/04_eventmanager-install.yaml -e ENTITLED_REGISTRY_KEY=eyJhbGciOiJIUzI1NiJ9.eyJpc3adsgJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1Nzg0NzQzMjgsImp0aSI6IjRjYTM3gsdgdMzExNjQxZDdiMDJhMjRmMGMxMWgdsmZhIn0.Z-rqfSLJA-R-ow__tI3RmLx4mssdggdabvdcgdgYEkbYY
```

This will install:

- CP4WAIOPS EventManager
- Gateway




