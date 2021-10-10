#!/bin/bash
docker image rm hisdad/diag:glibc-latest
time docker build -t hisdad/diag:glibc-latest  -f Dockerfile-glibc .
