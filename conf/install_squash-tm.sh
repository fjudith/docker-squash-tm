#! /bin/bash
# Download and install English or French version

echo "Installing Language:\"$SQUASH_TM_LANGUAGE\""
cd /usr/share
curl -L http://www.squashtest.org/telechargements/send/13-version-stable/265-stm-1160-targz | gunzip -c | tar x
