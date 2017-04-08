#! /bin/bash

# English build
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm:1.15.1 .
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm .
