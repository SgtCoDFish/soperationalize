#!/usr/bin/env bash

set -eu -o pipefail

PUBLIC_KEY_FILE=${1:-}

if [[ -z $PUBLIC_KEY_FILE ]]; then
	echo "usage: $0 <public key file>"
	exit 1
fi

# Show the key(s) in the given file without importing them into GPG.
# Show in machine readable form, selecting first only "pub" type keys (to avoid subkeys)
# and then grepping for the fingerprint (fpr) for each key. The actual fingerprint is in
# the 10th colon-separated column, so select that and print out

<$PUBLIC_KEY_FILE gpg --batch --no-default-keyring --import --import-options show-only --with-colons |
	grep -A1 pub |
	grep fpr |
	cut -d":" -f10
