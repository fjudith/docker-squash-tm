#! /bin/bash
# Download and install English or French version

echo "Installing Language:\"$SQUASH_TM_LANGUAGE\""
cd /usr/share
curl -L http://www.squashtest.org/downloads/send/11-archives/254-stm-1151-targz?lang=en | gunzip -c | tar x
