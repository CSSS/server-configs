# setup csss website server

# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
# https://itnext.io/setting-up-https-for-jenkins-with-nginx-everything-in-docker-4a118dc29127
# https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04
# https://wiki.jenkins.io/display/JENKINS/Jenkins+behind+an+NGinX+reverse+proxy
# https://stackoverflow.com/questions/33272054/how-can-i-get-docker-container-roots-password
# https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-18-04

useradd -m -d /home/csss -s /bin/bash csss
mkdir /home/csss/.ssh
cp /root/.ssh/authorized_keys /home/csss/.ssh/authorized_keys
chown -R csss:csss  /home/csss
chmod 700 /home/csss/.ssh
chmod 0600 /home/csss/.ssh/authorized_keys
echo "csss ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# login as csss
sudo apt update
sudo apt install software-properties-common
sudo apt install python3.8 python3-pip


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

sudo apt install postgresql-client-common
sudo apt-get install postgresql-client




mkdir dev
cd dev
git clone https://github.com/CSSS/csss-site.git
python3.8 -m pip install virtualenv
python3.8 -m virtualenv envCSSS
. envCSSS/bin/activate
cd csss-site
mkdir -p /home/csss/dev/csss-site/csss-site/src/logs
python3.8 -m pip install -r requirements.txt
echo "[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/home/csss/dev/gunicorn.sock

[Install]
WantedBy=sockets.target " | sudo tee /etc/systemd/system/gunicorn_dev.socket

echo "[Unit]
Description=gunicorn daemon
Requires=gunicorn_dev.socket
After=network.target

[Service]
EnvironmentFile=/home/csss/dev/site_envs
User=csss
Group=www-data
WorkingDirectory=/home/csss/dev/csss-site/csss-site/src
ExecStart=/home/csss/dev/envCSSS/bin/gunicorn \\
          --access-logfile - \\
          --workers 3 \\
          --bind unix:/home/csss/dev/gunicorn.sock \\
          csss.wsgi:application

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/gunicorn_dev.service

sudo systemctl start gunicorn_dev.socket
sudo systemctl enable gunicorn_dev.socket


sudo systemctl status gunicorn_dev.socket

file /home/csss/dev/gunicorn.sock
# Output
# /run/gunicorn.sock: socket

sudo journalctl -u gunicorn_dev.socket


# Take another look at your /etc/systemd/system/gunicorn.socket file to fix any problems before continuing.


sudo systemctl status gunicorn_dev


sudo systemctl daemon-reload
sudo systemctl restart gunicorn


# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python-certbot-nginx
sudo certbot certonly



sudo apt-get update
sudo apt-get install -y nginx

echo "server {
  listen 80;
  server_name ${website_fqdn};
  return 301 https://\$host\$request_uri;
}

server {
        listen 443 ssl;
        server_name ${website_fqdn};

        ssl_certificate /etc/letsencrypt/live/${website_fqdn}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${website_fqdn}/privkey.pem;

        location = /favicon.ico { access_log off; log_not_found off; }
        location /STATIC_URL/ {
                autoindex on;
                alias /home/csss/static_root/;
        }

        location /MEDIA_URL/ {
          autoindex on;
          alias /home/csss/media_root/;
        }

        location /dev/ {
                include proxy_params;
                proxy_pass http://unix:/home/csss/dev/gunicorn.sock;
        }
} " | sudo tee /etc/nginx/sites-available/website
sudo ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
