FINGERPRINT ?=

.PHONY: append-pgp-key-from-github
append-pgp-key-from-github: | bin  ## Adds PGP public keys from a given GitHub profile
ifeq ("$(GH_USERNAME)","")
	$(error Must set GH_USERNAME environment variable to use $@)
endif
	curl -sSL -o keys/pgp-keys/$(GH_USERNAME).asc "https://github.com/$(GH_USERNAME).gpg"

	./hack/pgp-fingerprints-from-file.sh keys/pgp-keys/$(GH_USERNAME).asc > "keys/$(GH_USERNAME)-github-$(DATE).pgp"

.PHONY: append-pgp-key-from-fingerprint
append-pgp-key-from-fingerprint: | bin  ## Adds PGP public key from a given fingerprint
ifeq ("$(GH_USERNAME)","")
	$(error Must set GH_USERNAME environment variable to use $@)
endif

ifeq ("$(FINGERPRINT)","")
	$(error Must set FINGERPRINT environment variable to use $@)
endif
	echo "$(FINGERPRINT)" > "keys/$(GH_USERNAME)-$(FINGERPRINT).pgp"

.PHONY: import-pgp-keys
import-pgp-keys: $(wildcard keys/pgp-keys/*.asc)  ## Imports all known PGP keys into local keyring so they can be used for encryption
	gpg --import $^
