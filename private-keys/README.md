# Private `age` Keys

⚠️ WARNING ⚠️

If `managed-secret-key.txt` exists in this directory, never share the contents of it; it contains a
**secret key** which might decrypt anything in `secrets.yaml`!

You should take care that if `managed-secret-key.txt` is lost without a backup, it will
be impossible for you to decrypt data using it and you'll have to register a new key.

## Info

This folder can be populated with an age identity generated for you by the tooling in the Makefile.

The identity will only be generated if you explicitly request it.

In the root directory which contains `.sops.yaml`, run `make managed-age-key` to generate:

- `managed-secret-key.txt` - the private key. Set to only be readable by the current user.
- `managed-public-key.txt` - the corresponding public key. This can be added to `.sops.yaml` via `make append-age-managed-key`.
