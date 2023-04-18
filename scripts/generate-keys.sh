#!/bin/bash -eux

openssl genrsa -out ~/private-keys/private-key.pem 4096
openssl rsa -in ~/private-keys/private-key.pem -pubout -out ~/public-keys/public-key.pem
cp ~/public-keys/public-key.pem ~/private-keys/
