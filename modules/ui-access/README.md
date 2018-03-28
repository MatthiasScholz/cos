# UI-Access module

This module contains terrafrom code for creating needed recources to access the ui's of cos components (i.e. fabio, nomad, consul).
The module creates:

* alb's, alb-attachments, ...

## How to use this module

* [ ] TODO: adjust this documentation

At [examples/parking](../../examples/parking/) there is a full running example (incl. minimal needed environment).

```bash
module "parking" {
  source = "git::ssh://git@git.mib3.technisat-digital/mib3-navigation/tsd.nav.cloud.infrastructure.modules.git?ref=snapshot//services/poi/modules/parking"

  # for parameters see vars.tf and the inputs section
}
```