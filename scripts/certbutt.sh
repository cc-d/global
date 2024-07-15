#!/bin/sh

echo -n "Enter your email address: "
read EMAIL

echo -n "Enter the domain or subdomain: "
read DOMAIN

echo -n "Enter the webroot path: "
read WEBROOT

certbot certonly --non-interactive --agree-tos --email "$EMAIL" \
    --webroot -w "$WEBROOT" -d "$DOMAIN"

echo "EMAIL: $EMAIL"
echo "WEBROOT: $WEBROOT"
echo "DOMAIN: $DOMAIN"
