AGE_PUBKEY ?=

.PHONY: managed-age-key
managed-age-key: private-keys/managed-secret-key.txt private-keys/managed-public-key.txt  ## Creates a new age secret key

private-keys/managed-secret-key.txt: | bin/age-keygen
	$(AGE_KEYGEN) -o $@
	chmod 600 $@

private-keys/managed-public-key.txt: private-keys/managed-secret-key.txt
	@$(AGE_KEYGEN) -y $< > $@

.PHONY: append-age-managed-key
append-age-managed-key: private-keys/managed-public-key.txt  ## Adds managed age secret key, generating if needed
ifeq ("$(GH_USERNAME)","")
	$(error Must set GH_USERNAME environment variable to use $@)
endif
	cat $< > "keys/$(GH_USERNAME)-$(shell cat $<).age"

.PHONY: append-age-single-key
append-age-single-key: ## Adds the given manually-generated age public key
ifeq ("$(GH_USERNAME)","")
	$(error Must set GH_USERNAME environment variable to use $@)
endif

ifeq ("$(AGE_PUBKEY)","")
	$(error Must set AGE_PUBKEY environment variable to use $@)
endif

	echo "$(AGE_PUBKEY)" > "keys/$(GH_USERNAME)-$(AGE_PUBKEY).age"
