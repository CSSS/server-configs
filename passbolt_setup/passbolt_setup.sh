# https://help.passbolt.com/hosting/install/ce/docker

create_box (){
	output="$@"
	greatestLength=0
	for i in "${output[@]}"
	do
		if [ $greatestLength -lt ${#i} ]; then
			greatestLength=${#i}
		fi
	done

	# section for printing top border
	echo; for i in $(seq $(($greatestLength + 8))); do echo -n "#"; done; echo
	echo -n "###"; for i in $(seq $(($greatestLength + 2))); do echo -n " "; done; echo "###"

	# sectiom for printing logs
	for i in "${output[@]}"
	do
		echo -n "### "$i
		for i in $(seq $(($greatestLength - ${#i} +1 ))); do echo -n " "; done;
		echo "###"
	done

	# section for printing bottom border
	echo -n "###"; for i in $(seq $(($greatestLength + 2))); do echo -n " "; done;	echo "###"
	for i in $(seq $(($greatestLength + 8))); do echo -n "#"; done;
	echo

}
index=1

while [ $index -lt $# ]
do
	echo "index="$index", \$#="$#
	if [ "${!index}" == "--password" ]; then
		index=$(($index+1))
		database_root_password="${!index}"
		index=$(($index+1))
	fi
	if [ "${!index}" == "--url" ]; then
		index=$(($index+1))
		network_url="${!index}"
		index=$(($index+1))
	fi
done

if [ "$network_url" == "" ]; then
	echo "it seems I got no url to assign to the passbolt instance"
	echo "Please re-run command and specify the url with \"--url\" flag"
	exit
fi

if [ "$database_root_password" == "" ]; then
	echo "it seems I got no root password to assign to the mariadb instance"
	echo "Please re-run command and specify the password with \"--password\" flag"
	exit
fi

output[0]="Recieved following variables from command-line"
output[1]="database_root_password="$database_root_password
output[2]="network_url="$network_url
create_box $output
unset $output

apt-get -y update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
. /etc/os-release
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${ID} $(lsb_release -cs) stable"
apt-get -y update
apt-get install -y docker-ce rng-tools
sudo systemctl status docker
docker pull passbolt/passbolt:latest
docker network create passbolt_network
docker run -d --name mariadb --net passbolt_network \
-e MYSQL_ROOT_PASSWORD=$database_root_password \
-e MYSQL_DATABASE=CSSS_PASSWORDS \
-e MYSQL_USER=CSSS \
-e MYSQL_PASSWORD=csss_passbolt mariadb
docker run -d --name passbolt --net passbolt_network -p 443:443 \
-p 80:80 -e DATASOURCES_DEFAULT_HOST=mariadb \
-e db_host=mariadb -e url=passbolt.dev \
-e DATASOURCES_DEFAULT_PASSWORD=csss_passbolt -e DATASOURCES_DEFAULT_USERNAME=CSSS \
-e DATASOURCES_DEFAULT_DATABASE=CSSS_PASSWORDS \
-e APP_FULL_BASE_URL=$network_url passbolt/passbolt:latest

docker exec passbolt su -m \
-c "/var/www/passbolt/bin/cake passbolt register_user -u j_manshad@sfu.ca -f Jace -l Manshadi -r admin"\
-s /bin/sh www-data
