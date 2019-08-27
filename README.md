# guacamole-packer 🥑📦 #

[![Build Status](https://travis-ci.com/cisagov/guacamole-packer.svg?branch=develop)](https://travis-ci.com/cisagov/guacamole-packer)

This project can be used to create machine images that include
[Apache Guacamole](https://guacamole.apache.org/), a clientless
remote desktop gateway.

## Pre-requisites ##

This project requires a build user to exist in AWS.  The accompanying terraform
code will create the user with the appropriate name and permissions.  This only
needs to be run once per project, per AWS account.  This user will also be used by
Travis-CI.

```console
cd terraform
terraform init --upgrade=true
terraform apply
```

Once the user is created you will need to update the `.travis.yml` file with the
new encrypted environment variables.

```console
terraform state show module.iam_user.aws_iam_access_key.key
```

Take the `id` and `secret` fields from the above command's output and [encrypt
and place in the `.travis.yml` file](https://docs.travis-ci.com/user/encryption-keys/).

Here is an example of encrypting the credentials for Travis:

```console
 travis encrypt --com --no-interactive "AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx"
 travis encrypt --com --no-interactive "AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
 travis encrypt --com --no-interactive "GITHUB_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

This project also requires the following data to exist in your [AWS Systems
Manager parameter store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html):

- `/cyhy/dev/users`: A comma-separated list of usernames of users that should
  be allowed to SSH to the instance based on this image
- `/ssh/public_keys/<username>`: The public SSH key of each user in the
  `/cyhy/dev/users` list
- `/guacamole/postgres_username`: The non-admin postgres username used by
  Guacamole
- `/guacamole/postgres_password`: The non-admin postgres password used by
  Guacamole

## Building the Image ##

### Using Travis-CI ###

1. Create a [new release](https://help.github.com/en/articles/creating-releases)
   in GitHub.
1. There is no step 2!

Travis-CI can build this project in three different modes depending on
how the build was triggered from GitHub.

1. **Non-release test**: After a normal commit or pull request Travis
   will build the project, and run tests and validation on the
   packer configuration.  It will __not__ build an image.
1. **Pre-release deploy**: Publish a GitHub release
   with the "This is a pre-release" checkbox checked.  An image will be built
   and deployed to the single region defined by the `PACKER_BUILD_REGION`
   environment variable.
1. **Production release deploy**: Publish a GitHub release with
   the "This is a pre-release" checkbox unchecked.  An image will be built
   in the `PACKER_BUILD_REGION` and copied to each region listed in the
   `PACKER_DEPLOY_REGION_KMS_MAP` environment variable.

### Using Your Local Environment ###

The following environment variables are used by Packer:

- Required
  - `PACKER_BUILD_REGION`: the region in which to build the image.
  - `PACKER_DEPLOY_REGION_KMS_MAP`: a map of deploy regions to KMS keys.
- Optional
  - `GITHUB_ACCESS_TOKEN`: a personal GitHub token to use for API access.
  - `PACKER_IMAGE_VERSION`: the version tag applied to the final image.

Here is an example of how to kick off a pre-release build:

```console
pip install --requirement requirements-dev.txt
export PACKER_BUILD_REGION="us-east-2"
export PACKER_DEPLOY_REGION_KMS_MAP="us-east-1:alias/cool/ebs,us-east-2:alias/cool/ebs,us-west-1:alias/cool/ebs,us-west-2:alias/cool/ebs"
export PACKER_IMAGE_VERSION=$(./bump_version.sh show)
ansible-galaxy install --force --role-file src/requirements.yml
./patch_packer_config.py pre-release src/packer.json
packer build --timestamp-ui src/packer.json
```

If you are satisfied with your pre-release image, you can easily create a release
that deploys to all regions by changing the `pre-release` command of
`patch_packer_config.py` to `release` and rerunning packer:

```console
./patch_packer_config.py release src/packer.json
packer build --timestamp-ui src/packer.json
```

See the patcher script's help for more information about its options and
inner workings:

```console
./patch_packer_config.py --help
```

## Contributing ##

We welcome contributions!  Please see [here](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
