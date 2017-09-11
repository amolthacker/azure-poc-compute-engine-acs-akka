#!/bin/bash
#----------------------------------------------------#
# 1. Login
#----------------------------------------------------#
$ az login
#----------------------------------------------------#

#----------------------------------------------------#
# 2. Deploy
#----------------------------------------------------#
$ cd acs-dcos-k8s
$ az group deployment create -g BTN-TDAKKA-RG01 --template-file dcos-1_9.azuredeploy.json --parameters @dcos-1_9.azuredeploy.parameters.json
#----------------------------------------------------#

#----------------------------------------------------#
# 3. SSH Tunnel and Master Node Setup
#----------------------------------------------------#
$ ssh -i ~/.ssh/az vtasadmin@tdsveritas-dcos-master.northcentralus.cloudapp.azure.com -p 2200 -L 8000:localhost:80

----------------
# In DCOS Master
----------------

# Install DCOS-CLI
vtasadmin@dcos-master-vtas-0:~$ curl https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.9/dcos -o dcos &&
sudo mv dcos /usr/local/bin &&
sudo chmod +x /usr/local/bin/dcos &&
dcos config set core.dcos_url http://localhost &&
dcos

# Install virtualenv
vtasadmin@dcos-master-vtas-0:~$ sudo apt-get update && sudo apt-get -y upgrade
vtasadmin@dcos-master-vtas-0:~$ sudo apt-get install python-pip
vtasadmin@dcos-master-vtas-0:~$ sudo pip install virtualenv

# Install Java
vtasadmin@dcos-master-vtas-0:~$ sudo apt-get install default-jre

# Install Go
vtasadmin@dcos-master-vtas-0:~$ mkdir downloads
vtasadmin@dcos-master-vtas-0:~$ cd downloads
vtasadmin@dcos-master-vtas-0:~/downloads$ wget https://storage.googleapis.com/golang/go1.7.5.linux-amd64.tar.gz
vtasadmin@dcos-master-vtas-0:~/downloads$ sudo tar -C /usr/local -xzf go1.7.5.linux-amd64.tar.gz
vtasadmin@dcos-master-vtas-0:~/downloads$ cd ~/

# Update PATH with Go bin and add to bash profile
# add following to ~/.profile

# Go
export PATH=$PATH:/usr/local/go/bin

# Install kube-mesos-framework
vtasadmin@dcos-master-vtas-0:~$ git clone https://github.com/kubernetes-incubator/kube-mesos-framework &&
cd kube-mesos-framework &&
make

# To teardown mesos framework
echo "frameworkId=23423-23423-234234-234234" | curl -d@- -X POST http://<mesos-master-ip>:5050/master/teardown




#----------------------------------------------------#