#!/usr/bin/env bash

DNSHOSTNAME="host.example.com" #Public FQDN of the DNS server
HOSTIP="1.2.3.4" #IP Address of the server running the containers

docker-compose down

# Prep work:
mkdir -p /etc/coredns
cp ./coreconfig* /etc/coredns/
echo 'HOST_IP='$HOSTIP > ./.env
sed -i 's/{HOSTIP}/'"$HOSTIP"'/g' /etc/coredns/coreconfig-down

docker run -it --rm --name certbot \
	-v "/etc/letsencrypt:/etc/letsencrypt" \
	-v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
	-p "80:80" \
	certbot/certbot certonly -n --standalone --register-unsafely-without-email --agree-tos --cert-name coredns --domain $DNSHOSTNAME

docker-compose up -d --force-recreate