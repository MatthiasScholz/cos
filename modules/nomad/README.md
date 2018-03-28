# Nomad module

This module contains terrafrom code for setting up a nomad cluster.
The module creates:

* nomad-servers (datacenter: backoffice-master), nomad-clients (datacenter: public-services, private-services, backoffice, content-connector)

## How to use this module

* [ ] TODO: adjust this documentation

At [examples/parking](../../examples/parking/) there is a full running example (incl. minimal needed environment).

```bash
module "parking" {
  source = "git::ssh://git@git.mib3.technisat-digital/mib3-navigation/tsd.nav.cloud.infrastructure.modules.git?ref=snapshot//services/poi/modules/parking"

  # for parameters see vars.tf and the inputs section
}
```

## consul_cluster_tag_key and -value

The variables ```consul_cluster_tag_key``` and ```consul_cluster_tag_value``` are important for creating a running nomad-cluster using consul. These are required to be set correctly to ensure that the nomad-instances are able to find the consul-server instances and register themselves.

```consul_cluster_tag_key```: Defines the name of the tag which was used to tag the consul-server nodes. Usually this is ```consul-servers```.
```consul_cluster_tag_value```: Defines the value of the ```consul_cluster_tag_key``` that was used to tag the consul-server nodes. Usually this is the name of the consul-server instances.

On each nomad instance there is a consul-agent that tries to find the consul-server instances for being able to register the nomad instances in order to form a nomad cluster.

If, for example, the consul-server EC2 instances are tagged with ```consul-server:my-consul-instance```, then ```consul_cluster_tag_key="consul-server"``` and ```consul_cluster_tag_value="my-consul-instance"```