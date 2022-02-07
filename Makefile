SHELL := /usr/bin/env bash

WORKDIR := $(shell pwd)

AGE ?= bin/age
AGE_KEYGEN ?= bin/age-keygen

SOPS_AGE_KEY_FILE ?= $(WORKDIR)/private-keys/managed-secret-key.txt
SOPS ?= SOPS_AGE_KEY_FILE=$(SOPS_AGE_KEY_FILE) bin/sops

SOPS_VERSION=v3.7.1
AGE_VERSION=v1.0.0

DATE := $(shell date --rfc-3339=date)

GH_USERNAME ?=

.DELETE_ON_ERROR:

include make/age-automation.mk
include make/pgp-automation.mk

.PHONY: open
open: bin/sops ## Key required: Open the file for editing in plaintext
	$(SOPS) secrets.yaml

.PHONY: updatekeys
updatekeys: .sops.yaml bin/sops ## Key required: Ensures that the file has been encrypted with each of the public keys in .sops.yaml, so that all team members can decrypt individually
	$(SOPS) updatekeys -y secrets.yaml

# This isn't an ideal way of generating a YAML file, but it works!

.PHONY: .sops.yaml
.sops.yaml: $(wildcard keys/*.pgp) $(wildcard keys/*.age) import-pgp-keys
	echo "creation_rules:" > $@
	echo -n "- age: " >> $@
	cat $(wildcard keys/*.age) | xargs | sed -e 's/ /,/g' >> $@
	echo -n "  pgp: " >> $@
	cat $(wildcard keys/*.pgp) | xargs | sed -e 's/ /,/g' >> $@

.PHONY: tools
tools: bin/sops bin/age-keygen ## Installs required tools into the bin/ directory

bin/sops: | bin
	GOBIN=$(WORKDIR)/$(dir $@) go install go.mozilla.org/sops/v3/cmd/sops@$(SOPS_VERSION)

bin/age-keygen: | bin
	GOBIN=$(WORKDIR)/$(dir $@) go install filippo.io/age/cmd/age-keygen@$(AGE_VERSION)

bin:
	@mkdir -p $@

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
