# sso-me
Login to aws using SSO and write credentials to your aws credentials file

## Requirements
This tool depends on the `aws` cli v2 and `jq`. 

Installation instructions for `aws` cli can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

Installation instructions for `jq` can be found [here](https://stedolan.github.io/jq/download/).

## Installing
Run `./install.sh` to install to your `/usr/local/bin` directory

## Usage

You will need a `~/.aws/config` file with the following:

```
[default]
sso_start_url=<your value>
sso_region=<your value>
sso_account_id=<your value>
sso_role_name=<your value>
region=<your value>
```

Then run `sso-me` to login to aws using SSO and write credentials to your aws credentials file.