#!/bin/bash
docker image rm hisdad/diag:diag-latest
time docker build -t hisdad/diag:diag-latest  -f Dockerfile-diag .
