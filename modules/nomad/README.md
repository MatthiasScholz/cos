# Nomad module

This module contains terrafrom code for setting up a nomad cluster.
The module creates:

* nomad-servers (datacenter: backoffice-master), nomad-clients (datacenter: public-services, private-services, backoffice, content-connector)

## How to use this module

At [examples/nomad](../../examples/nomad/) there is a full running example (incl. minimal needed environment).

```bash
module "nomad" {
  source = "git::https://github.com/MatthiasScholz/cos.git/modules/nomad?ref=v0.2.0.

  # for parameters see vars.tf and the inputs section
}
```

## consul_cluster_tag_key and -value

The variables ```consul_cluster_tag_key``` and ```consul_cluster_tag_value``` are important for creating a running nomad-cluster using consul. These are required to be set correctly to ensure that the consul-agents (on the nomad instances) are able to find the consul-server instances and register themselves.

```consul_cluster_tag_key```: Defines the name of the tag which was used to tag the consul-server nodes. Usually this is ```consul-servers```.
```consul_cluster_tag_value```: Defines the value of the ```consul_cluster_tag_key``` that was used to tag the consul-server nodes. Usually this is the name of the consul-server instances.

On each nomad instance there is a consul-agent that tries to find the consul-server instances for being able to form a consul cluster.

If, for example, the consul-server EC2 instances are tagged with ```consul-server:my-consul-instance```, then ```consul_cluster_tag_key="consul-server"``` and ```consul_cluster_tag_value="my-consul-instance"```
