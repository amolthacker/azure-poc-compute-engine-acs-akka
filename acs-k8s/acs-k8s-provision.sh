#!/bin/bash

#----------------------------------------------------#
# 1. Generate K8S Provisioning ARM Template
#----------------------------------------------------#
$ cd <PROJ_DIR>/acs-k8s
$ acs-engine acs-engine-k8s-cdf.json
#----------------------------------------------------#

#----------------------------------------------------#
# 2. Login & Select Subscription
#----------------------------------------------------#
$ az login
$ az account set --subscription <SUBSCRIPTION NAME OR ID>
#----------------------------------------------------#

#----------------------------------------------------#
# 3. Deploy
#----------------------------------------------------#
$ cd acs-k8s/_output/Kubernetes-<NNNN>
$ az group deployment create --name compute-engine-akka_acs-k8s -g BTN-TDAKKA-RG01 --template-file azuredeploy.json --parameters @azuredeploy.parameters.json
#----------------------------------------------------#

#----------------------------------------------------#
# 5. Start K8S Proxy & Clone Project in K8s Master Node
#----------------------------------------------------#
$ ssh -i ~/.ssh/az vtasadmin@tdsveritas.northcentralus.cloudapp.azure.com
vtasadmin@k8s-master-29533770-0:~$ nohup kubectl proxy > k8s-proxy.out 2>&1&

vtasadmin@k8s-master-29533770-0:~$ mkdir -p tds-veritas/compute/compute-engine-akka
vtasadmin@k8s-master-29533770-0:~$ cd tds-veritas/compute/compute-engine-akka
vtasadmin@k8s-master-29533770-0:~$ git clone https://github.com/amolthacker/azure-poc-compute-engine-acs-akka.git .
$ az account set --subscription <SUBSCRIPTION NAME OR ID>
#----------------------------------------------------#

#----------------------------------------------------#
# 6. Deploy K8S Akka Cluster
#----------------------------------------------------#

# VE Service
vtasadmin@k8s-master-29533770-0:~/tds-veritas/compute/compute-engine-akka$ kubectl apply -f k8s/ve-svc.yaml

# VE Controller Seed Nodes
vtasadmin@k8s-master-29533770-0:~/tds-veritas/compute/compute-engine-akka$ kubectl apply -f k8s/ve-ctrl.yaml

# VE Engine Workers
vtasadmin@k8s-master-29533770-0:~/tds-veritas/compute/compute-engine-akka$ kubectl apply -f k8s/ve.yaml
#----------------------------------------------------#

#----------------------------------------------------#
# 7. Expose Service
#----------------------------------------------------#
vtasadmin@k8s-master-29533770-0:~/tds-veritas/compute/compute-engine-akka$ kubectl expose service ve-ctrl --type=LoadBalancer --name=ve-ctrl-ext
#----------------------------------------------------#

#----------------------------------------------------#
# 8. Submit Jobs
#----------------------------------------------------#
$ curl -X GET '<service-url>/valQuery?metric=<NPV|FwdRate|OptionPV>&numTrades=<numTrades>'
$ ./bin/submit-compute-batch -n 10 -s tds-veritas-akka.northcentralus.cloudapp.azure.com
#----------------------------------------------------#

#----------------------------------------------------#
# 9. Teardown K8S Akka Cluster
#----------------------------------------------------#
vtasadmin@k8s-master-29533770-0:~/tds-veritas/compute/compute-engine-akka$ kubectl delete -f k8s/
#----------------------------------------------------#

