# Keys

This directory contains age public keys and ASCII-armored PGP public keys for each key which is to be listed in `.sops.yaml`.

## `pgp-keys/`

For every PGP key whose fingerprint is listed in this directory, there must be a corresponding ASCII-armored public key
in `pgp-keys/`.

This is required so that the GPG tool can import each public key locally. That's needed before the keys can be used for encryption.

`age` keys don't have this requirement; for `age`, all that's required is the public key string.
