#! /bin/bash

# English build
docker build --tag=fjudith/squash-tm:1.15.3 .
docker build --tag=fjudith/squash-tm .
