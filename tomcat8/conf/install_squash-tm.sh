#! /bin/bash
# Download and install English or French version

echo "Installing Language:\"$SQUASH_TM_LANGUAGE\""

if [ "$SQUASH_TM_LANGUAGE" == "en" ]; then
	cd /usr/share
	curl -L http://www.squashtest.org/downloads/send/13-version-stable/230-squashtm-140-targz-2?lang=en | gunzip -c | tar x
fi

if [ "$SQUASH_TM_LANGUAGE" == "fr" ]; then
	cd /usr/share
	curl -L http://www.squashtest.org/telechargements/send/13-version-stable/230-squashtm-140-targz-2?lang=fr | gunzip -c | tar x
fi