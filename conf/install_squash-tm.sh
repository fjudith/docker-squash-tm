#! /bin/bash
# Download and install English or French version

echo "Installing Language:\"$SQUASH_TM_LANGUAGE\""
cd /usr/share
curl -L http://www.squashtest.org/downloads/send/13-version-stable/245-stm-1142-targz?lang=en | gunzip -c | tar x
