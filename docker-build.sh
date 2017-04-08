#! /bin/bash

# English build
docker build --tag=fjudith/squash-tm:1.15.1 .
docker build --tag=fjudith/squash-tm .
