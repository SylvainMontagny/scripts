#!/bin/bash
TTS_DIR="$HOME/tts"

clear
if [ -z $1 ] || [ $1 = "help" ]
then
	echo "INFO : First argument must be the domain name"
    #echo "INFO : Second argument is optionnal : port number for UDP Packet Forwarder"
    exit
else
	echo "Le nom de domaine est $1"
fi


if [ -d "$TTS_DIR" ]; then
    cd $TTS_DIR
    sudo docker-compose down 
    sudo rm -rf $TTS_DIR
fi

cd $HOME
mkdir tts
cd tts
wget https://www.thethingsindustries.com/docs/getting-started/installation/configuration/docker-compose-open-source.yml
mv docker-compose-open-source.yml docker-compose.yml
wget https://www.thethingsindustries.com/docs/getting-started/installation/configuration/ttn-lw-stack-docker-open-source.yml
mv ttn-lw-stack-docker-open-source.yml ttn-lw-stack-docker.yml
sed -i -e "s/thethings.example.com/$1/g" ttn-lw-stack-docker.yml
mkdir -p config/stack
mv ttn-lw-stack-docker.yml config/stack
mkdir ./acme
sudo chown 886:886 ./acme
sudo docker-compose pull
sudo docker-compose run --rm stack is-db init
sudo docker-compose run --rm stack is-db create-admin-user --id admin --email your@email.com
sudo docker-compose run --rm stack is-db create-oauth-client --id cli --name "Command Line Interface" --owner admin --no-secret --redirect-uri "local-callback" --redirect-uri "code"
sudo docker-compose run --rm stack is-db create-oauth-client --id console --name "Console" --owner admin --secret 'console' --redirect-uri "https://$1/console/oauth/callback" --redirect-uri "/console/oauth/callback" --logout-redirect-uri "https://ttn1.$1/console" --logout-redirect-uri "/console"
sudo docker-compose up -d