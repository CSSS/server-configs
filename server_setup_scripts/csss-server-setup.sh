# setup csss server

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
# https://itnext.io/setting-up-https-for-jenkins-with-nginx-everything-in-docker-4a118dc29127
# https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04
# https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy
# https://stackoverflow.com/questions/33272054/how-can-i-get-docker-container-roots-password

useradd -m -d /home/csss -s /bin/bash csss
mkdir /home/csss/.ssh
cp /root/.ssh/authorized_keys /home/csss/.ssh/authorized_keys
chown -R csss:csss  /home/csss
chmod 700 /home/csss/.ssh
chmod 0600 /home/csss/.ssh/authorized_keys
echo "csss ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

sudo apt-get update
sudo apt-get install -y nginx

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python-certbot-nginx
sudo certbot certonly

sudo apt-get update

# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
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
sudo usermod -aG docker csss

#https://docs.docker.com/compose/install/#install-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo apt-get install -y haveged #https://github.com/docker/compose/issues/6678

## copy configs under nginx_configs to /etc/nginx/sites-available/

## start dockerized jenkins
docker run \
    -d \
    -v \
    /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/bin/docker \
    -v $(which docker-compose):/bin/docker-compose \
    -e VIRTUAL_HOST=jenkins.sfucsss.org \
    -p 8080:8080 \
    --name csss_jenkins \
    sfucsssorg/csss_jenkins

sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# verify chain cert with https://whatsmychaincert.com/?jenkins.sfucsss.org


# https://help.passbolt.com/hosting/install/ce/docker.html
apt-get install -y rng-tools
sudo systemctl status docker
docker network create passbolt_network
docker run -d --name passwords_mariadb --net passbolt_network \
-e MYSQL_ROOT_PASSWORD=<MYSQL_ROOT_PASSWORD> \
-e MYSQL_DATABASE=CSSS_PASSWORDS \
-e MYSQL_USER=CSSS \
-e MYSQL_PASSWORD=<MYSQL_PASSWORD> mariadb
docker run -d --name csss_passwords --net passbolt_network -p 8081:80 \
-e EMAIL_TRANSPORT_DEFAULT_CLASS_NAME=Smtp \
-e EMAIL_DEFAULT_FROM=csss.psswds@gmail.com \
-e EMAIL_DEFAULT_TRANSPORT=default \
-e EMAIL_TRANSPORT_DEFAULT_HOST=smtp.gmail.com \
-e EMAIL_TRANSPORT_DEFAULT_PORT=587 \
-e EMAIL_TRANSPORT_DEFAULT_TLS=true \
-e EMAIL_TRANSPORT_DEFAULT_USERNAME=csss.psswds@gmail.com \
-e EMAIL_TRANSPORT_DEFAULT_PASSWORD=<csss.passwds app specific password> \
-e DATASOURCES_DEFAULT_HOST=passwords_mariadb \
-e db_host=mariadb \
-e DATASOURCES_DEFAULT_PASSWORD=<MYSQL_ROOT_PASSWORD> -e DATASOURCES_DEFAULT_USERNAME=CSSS \
-e DATASOURCES_DEFAULT_DATABASE=CSSS_PASSWORDS \
-e APP_FULL_BASE_URL="https://passwords.sfucsss.org" passbolt/passbolt:latest

docker exec csss_passwords su -m -c "/var/www/passbolt/bin/cake \
passbolt register_user \
-u csss@sfu.ca \
-f CS \
-l Society \
-r admin" \
-s /bin/sh www-data

sudo ln -s /etc/nginx/sites-available/passwords /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

sudo apt-get install postgresql-client
sudo apt install postgresql-client-common
