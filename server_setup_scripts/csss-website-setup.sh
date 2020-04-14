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

git clone https://github.com/CSSS/csss-site.git
python3.8 -m pip install virtualenv
python3.8 -m virtualenv envCSSS
. envCSSS/bin/activate
cd csss-site
mkdir -p /home/csss/csss-site/csss-site/src/logs
python3.8 -m pip install -r requirements.txt
echo "
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
" | sudo tee /etc/systemd/system/gunicorn.socket

echo "
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
EnvironmentFile=/home/csss/site_envs
User=csss
Group=www-data
WorkingDirectory=/home/csss/csss-site/csss-site/src
ExecStart=/home/csss/envCSSS/bin/gunicorn \\
          --access-logfile - \\
          --workers 3 \\
          --bind unix:/run/gunicorn.sock \\
          csss.wsgi:application

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/gunicorn.service

sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket


sudo systemctl status gunicorn.socket

file /run/gunicorn.sock
# Output
# /run/gunicorn.sock: socket

sudo journalctl -u gunicorn.socket


# Take another look at your /etc/systemd/system/gunicorn.socket file to fix any problems before continuing.


sudo systemctl status gunicorn


sudo systemctl daemon-reload
sudo systemctl restart gunicorn

sudo apt-get update
sudo apt-get install -y nginx

echo "
server {
  listen 80;
  server_name ${the_website_url};
  return 301 https://\$host\$request_uri;
}

server {
        listen 443 ssl;
        server_name ${the_website_url};

        ssl_certificate /etc/letsencrypt/live/${the_website_url}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${the_website_url}/privkey.pem;

        location = /favicon.ico { access_log off; log_not_found off; }
        location /STATIC_URL/ {
                autoindex on;
                alias /home/csss/static_root/;
        }

        location /MEDIA_URL/ {
          autoindex on;
          alias /home/csss/media_root/;
        }

        location / {
                include proxy_params;
                proxy_pass http://unix:/run/gunicorn.sock;
        }
}

" | sudo tee /etc/nginx/sites-available/website
sudo ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx



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

sudo apt install postgresql-client-common
sudo apt-get install postgresql-client
