#!/bin/bash
# install required package
apt-get update
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    gnupg-agent \
    software-properties-common

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
# add user to docker group to make docker accessible without sudo
gpasswd -a ubuntu docker

# install java
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
apt-add-repository "deb http://repos.azul.com/azure-only/zulu/apt stable main"
apt-get -q update
apt-get -y install zulu-11-azure-jdk

# install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.5/bin/linux/amd64/kubectl
chmod +555 ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# install helm 3 latest
curl https://helm.baltorepo.com/organization/signing.asc | apt-key add -
apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm
ln -s /usr/sbin/helm /usr/sbin/helm3

# install kubeseal
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.9.5/kubeseal-linux-amd64 -O kubeseal
install -m 755 kubeseal /usr/local/bin/kubeseal

# install chromium
apt install -y chromium-browser

# install VNC server
apt -y install xfce4 xfce4-goodies
apt -y install tightvncserver

# install kubectl autocompletion
kubectl completion bash >/etc/bash_completion.d/kubectl

# install font
apt install fonts-ipafont fonts-ipaexfont -y

# install aws cli
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
./aws/install