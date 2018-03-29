# UI-Access module

This module contains terrafrom code for creating needed recources to access the ui's of cos components (i.e. fabio, nomad, consul).
The module creates:

* alb's, alb-attachments, ...

## How to use this module

At [examples/ui-access](../../examples/ui-access/) there is a full running example (incl. minimal needed environment).

```bash
module "ui-access" {
  source = "../../modules/ui-access"

  ## required parameters
  vpc_id                 = # ....
  subnet_ids             = # ....
  nomad_server_asg_name  = # ....
  consul_server_asg_name = # ....
  fabio_server_asg_name  = # ....
}
```