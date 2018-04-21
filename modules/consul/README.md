# Consul module

This module contains terrafrom code for setting up a consul cluster.
The module creates:

* consul-servers (datacenter: ```aws_region```)

## How to use this module

At [examples/consul](../../examples/consul/) there is a full running example (incl. minimal needed environment).

```bash
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

module "consul" {
  source     = "../../modules/consul"
  aws_region = "eu-central-1"
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.all.ids}"
  ami_id     = "ami-a23feadf"
}
```

## cluster_tag_key and -value

The variables ```cluster_tag_key``` and ```cluster_tag_value``` are important for creating a running cluster using consul. These are required to be set correctly to ensure that the consul-agents (i.e. on the nomad instances) are able to find the consul-server instances and register themselves.

```cluster_tag_key```: Defines the name of the tag which was used to tag the consul-server nodes. Usually this is ```consul-servers```.
```cluster_tag_value```: Defines the value of the ```cluster_tag_key``` that was used to tag the consul-server nodes. Usually this is the name of the consul-server instances.

## ami_id

The ami that is used has to contain the consul binary.