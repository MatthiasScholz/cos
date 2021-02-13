# Overview - Nomad 1.0.2

- Release date: 2021-02-13

## Changes

- :tada: Upgrade of all dependencies.
- :construction_worker: Automation of the release process.

### Incompatilbe Changes

- Replace SSH access with AWS System Manager Session Manager (AWS SSM)
  as default configuration to access the instances in the [examples](../../examples) folder.
  This DOES NOT decrease the functionality of the terraform modules usage itself.

## Included Versions

- nomad: 1.0.2
- consul: 1.9.3
- fabio: 1.5.15
- terraform: 0.14

### Terraform Modules

- terraform-aws-nomad: 0.7.2
- terraform-aws-consul: 0.8.4

## Release Branch

- releases/v0.4.0

## Disclaimer

Do not use the out of the box configuration for your production setup
especially security and cluster access needs to be restricted better.
