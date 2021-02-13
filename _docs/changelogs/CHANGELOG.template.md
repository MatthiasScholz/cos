# Overview

- Release date: {{ env "release_date" }}

## Changes

-

## Included Versions

- nomad: {{ env "version_nomad" }}
- consul: {{ env "version_consul" }}
- fabio: {{ env "version_fabio" }}
- terraform: {{ env "version_terraform" }}

### Terraform Modules

- terraform-aws-nomad: {{ env "version_tf_nomad" }}
- terraform-aws-consul: {{ env "version_tf_consul" }}

## Release Branch

- releases/{{ env "release_version" }}

## Disclaimer

Do not use the out of the box configuration for your production setup
especially security and cluster access needs to be restricted better.
