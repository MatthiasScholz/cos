# Overview

- Release date: 2019-10-21

## Changes

- **major (incompatible)**, Refactor: With [#70](https://github.com/MatthiasScholz/cos/issues/70) the cos module was upgraded to be compatible to terraform 0.12.0.
  - Furthermore the depending modules where upgraded as well:
    - terraform-aws-consul from [v0.3.1](https://github.com/hashicorp/terraform-aws-consul/tree/v0.3.1) to [v0.7.0](https://github.com/hashicorp/terraform-aws-consul/tree/v0.7.0)
    - terraform-aws-nomad from [v0.4.5](https://github.com/hashicorp/terraform-aws-nomad/tree/v0.4.5) to [v0.5.0](https://github.com/hashicorp/terraform-aws-nomad/tree/v0.5.0)
- License: With [9156e49](https://github.com/MatthiasScholz/cos/commit/9156e49f0eabbfc50100aeb778e6a776ba376b96) the license model was changed from GPL to LGPL, a more relaxed one.
- Test: With PR [#68](https://github.com/MatthiasScholz/cos/pull/68) tests (terratest) where added to ensure functionality of the COS.

## Release Branch

- releases/v0.2.0

## Disclaimer

Do not use the out of the box configuration for your production setup
especially security and cluster access needs to be restricted better.
