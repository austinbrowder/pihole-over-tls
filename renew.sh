#!/usr/bin/env bash

DNSHOSTNAME="host.example.com"
echo "=================cert renewal starting========================"
echo $(date -u)

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )"

docker run -t --rm --name certbot \
	-v "/etc/letsencrypt:/etc/letsencrypt" \
	-v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
	-p "80:80" \
	certbot/certbot certonly -n --standalone --register-unsafely-without-email --agree-tos --cert-name coredns --domain $DNSHOSTNAME

docker-compose up -d --force-recreate
echo "=================cert renewal complete========================="