#! /bin/bash

# ENglish build
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm:1.14.2 .
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm .

# French Build
docker build --build-arg=SQUASH_TM_LANGUAGE=fr --tag=fjudith/squash-tm:1.14.2-fr .
docker build --build-arg=SQUASH_TM_LANGUAGE=fr --tag=fjudith/squash-tm:fr .