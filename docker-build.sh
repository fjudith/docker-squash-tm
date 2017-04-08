#! /bin/bash

# English build
docker build --tag=fjudith/squash-tm:1.15.0 .
docker build --tag=fjudith/squash-tm .
