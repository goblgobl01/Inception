#!/bin/bash

mkdir -p /ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /ssl/cert_key.key -out /ssl/certifcate.crt \
	-subj "/C=MA/ST=Tetouan/L=Tetouan/O=42/OU=42/CN=mmaarafi.42.fr"