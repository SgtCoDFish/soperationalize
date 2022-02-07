#!/usr/bin/env bash

set -eu -o pipefail

FINGERPRINT=${1:-}
FRIENDLY_NAME=${2:-}

# Searches for the given fingerprint in .sops.yaml, failing if one is found
# This isn't used; it was for a previous design which didn't work out

if [[ -z $FINGERPRINT ]] || [[ -z $FRIENDLY_NAME ]] ; then
	echo "usage: $0 <fingerprint> <friendly name for key type>"
	exit 1
fi


if grep "$FINGERPRINT" .sops.yaml >/dev/null ; then
	echo "FATAL: $FRIENDLY_NAME '$FINGERPRINT' already exists in .sops.yaml"
	exit 1
fi
