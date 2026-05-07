#!/bin/bash

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/mmaarafi.42.fr.key \
	-out /etc/nginx/ssl/mmaarafi.42.fr.crt \
	-subj "/C=MA/ST=Tetouan/L=Tetouan/O=42/OU=42/CN=mmaarafi.42.fr"