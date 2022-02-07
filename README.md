# soperationalize

Operationalizing Mozilla's [sops](https://github.com/mozilla/sops) tool sharing secrets across a distributed open
source team spanning multiple companies.

We assume that onboarding a new user (or equivalently, a user changing or adding encryption
keys) is a reasonably rare occurrence. As such. we skip automating the onboarding process for
simplicity's sake.

## General Usage

Simply clone this repo. Everything is contained within it, including the encrypted secrets themselves.

Generally, all tasks can be done through interacting with `make` targets. The only required dependencies are GNU coreutils and the `go` command (for installing binaries).

## Reading and Editing Secrets

If you have access to the secret key corresponding to one of the identities listed in `.sops.yaml`
you can view and edit `secrets.yaml` in plaintext:

```bash
make open
```

## Updating Encrypted Secrets

If you've added a new key via one of the methods below - whether `age` or PGP - `secrets.yaml` must
be updated before that new key can decrypt anything.

### If You Already Have a Key

As long as you have at least one key which can decrypt `secrets.yaml`, you can update everything in a single
command:

```bash
make updatekeys
```

Once you've updated, you can raise a pull request with everything as-is.

### If You Don't Have a Key

This would be common when onboarding a new user or replacing lost keys for an existing user.

In this case, either:

- send a key to someone who does have a private key so they can raise a pull request for you
- or raise a pull request with their key added in `keys/` (and `keys/pgp-keys` for PGP) and ensure that [maintainers can edit the pull request](https://help.github.com/en/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork). One of the maintainers can then run `make updatekeys` on the branch locally, which should pick up the new key.

## Adding a New Key

[`age`](https://github.com/FiloSottile/age) is the best choice for generating a key locally and
there are helpers to automate the process of generating a key and adding it to `.sops.yaml`.

Adding a key varies depending on the type of key. The simplest and most secure way to get started
is to have the tooling generate a new `age` key entirely automatically.

**NB:** Adding a key isn't enough to use it for encrypting secrets! You'll also need to run
`make updatekeys` (described above) for that.

### Adding an `age` Key

#### Generating + Adding an `age` Key

👉 This is the simplest case.

To generate a new managed key and append it to `.sops.yaml` automatically, run:

```bash
make GH_USERNAME="<github username>" append-age-managed-key
```

That's it! 🎉 There's nothing more to do in this case except to make sure that you don't lose
`age/managed-secret-key.txt`!

#### Adding an Existing `age` Key

If you have an existing `age` key which you want to use, there's a helper:

```bash
make GH_USERNAME="<github-username>" AGE_PUBKEY="<public-key>" append-age-single-key
```

### Adding a PGP Key

⚠️ PGP is not recommended; there are [many reasons it's a bad choice today](https://latacora.micro.blog/2019/07/16/the-pgp-problem.html). Where possible, use `age` instead.

There are multiple ways PGP keys can fail; they can not be valid for encryption, or they can expire, or they could have
some invalid text in their ASCII-armored representation which makes them unparseable.

If you choose to use PGP keys, you **must** remember to put the ASCII-armored public key into `keys/pgp-keys/`. When fetching from GitHub this happens automatically, but if adding a key manually other users will not be able to encrypt
secrets for you unless they have your ASCII-armored key!

#### From GitHub

If you happen to use git commit signing and you have your PGP key(s) registered on GitHub, use the
following command to download your GitHub key(s) and add to `.sops.yaml`:

```bash
make GH_USERNAME=<your-username> append-pgp-key-from-github
```

#### Locally

If you want to add a PGP key which isn't registered on GitHub, place the ASCII-armored public key
file in `pgp-keys` with a sensible name, then do the following:

```bash
./hack/pgp-fingerprints-from-file.sh pgp-keys/<yourkeyfile>

make GH_USERNAME="<your-gh-username>" FINGERPRINT="<output from above command>" append-pgp-key-from-fingerprint
```

### (Not) Adding KMS Keys

sops supports KMS providers, but the catch with those providers is that the other open-source
maintainers on your project must have permissions to encrypt (but not necessarily to decrypt) using
the KMS keys you want to configure - otherwise, they won't be able to update `secrets.yaml`.

It's assumed that most humans will use either PGP or - preferably - `age` keys.

Adding KMS keys will be done by manually appending the relevant information to `.sops.yaml`. See
the [sops README](https://github.com/mozilla/sops) for more information.
