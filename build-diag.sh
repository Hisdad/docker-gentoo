#!/bin/bash
docker image rm hisdad/diag:diag-latest
time docker build -t hisdad/diag:diag-latest --no-cache -f Dockerfile-diag .
