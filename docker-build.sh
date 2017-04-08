#! /bin/bash

# English build
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm:1.15.0 .
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm .
