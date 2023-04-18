#!/bin/bash -eux

openssl genrsa -out ~/private-keys/private.pem 4096
openssl rsa -in ~/private-keys/private.pem -pubout -out ~/public-keys/public.pem
cp ~/public-keys/public.pem ~/private-keys/
