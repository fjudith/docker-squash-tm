#! /bin/bash

# English build
docker build --tag=fjudith/squash-tm:1.16.0 .
docker build --tag=fjudith/squash-tm .
