# setup csss server

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
# https://itnext.io/setting-up-https-for-jenkins-with-nginx-everything-in-docker-4a118dc29127
# https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04
# https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy

useradd -m -d /home/jace -s /bin/bash jace
mkdir /home/jace/.ssh
cp /root/.ssh/authorized_keys /home/jace/.ssh/authorized_keys
chown -R jace:jace  /home/jace
chmod 700 /home/jace/.ssh
chmod 0600 /home/jace/.ssh/authorized_keys
echo "jace ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo apt-get update
sudo apt-get install -y nginx
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python-certbot-nginx
sudo certbot certonly

sudo apt-get update

#instal docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker jace

#install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo apt-get install -y haveged #https://github.com/docker/compose/issues/6678
