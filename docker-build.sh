#! /bin/bash
http://repo.squashtest.org/distribution/squash-tm-1.14.2.RELEASE.zip
# International build
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm:1.14.2 .
docker build --build-arg=SQUASH_TM_LANGUAGE=en --tag=fjudith/squash-tm .