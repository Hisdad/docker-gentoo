#!/bin/bash
docker image rm hisdad/diag:php-latest
time docker build -t hisdad/diag:php-latest  -f Dockerfile-php .
