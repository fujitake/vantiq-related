
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
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# add user to docker group to make docker accessible without sudo
gpasswd -a ubuntu docker

# install java
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
apt-get -q update
apt-get -y install zulu11-jdk

# install kubectl
curl -LO https://dl.k8s.io/release/v1.32.7/bin/linux/amd64/kubectl
chmod +555 ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# install helm 3 latest
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm
ln -s /usr/sbin/helm /usr/sbin/helm3

# install kubeseal
#wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.9.5/kubeseal-linux-amd64 -O kubeseal
#install -m 755 kubeseal /usr/local/bin/kubeseal

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
