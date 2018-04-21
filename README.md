# Basic Cluster Orchestration System

Making use of terraform and nomad to setup a cluster orchestration system.
This respository will provide an extended example from the main [nomad terraform module](https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-separate-cluster)

## Structure

### _docs

Providing detailed documentation for this module.

### examples

Provides example instanziation of this module.

### modules

Terraform modules for separate aspects of the cluster orchestration system.

* [nomad](modules/nomad): Module building up a nomad cluster.
* [consul](modules/consul): Module building up a consul cluster.
* [ui-access](modules/ui-access): Module building up alb's to grant access to nomad-, consul- and fabio-ui.
* [ami](modules/ami): Module for creating an AMI having nomad, consul and docker installed (based on Amazon Linux AMI 2017.09.1 .
* [ami2](modules/ami2): Module for creating an AMI having nomad, consul and docker installed (based on AAmazon Linux 2 LTS Candidate AMI 2017.12.0).

#### Dependencies

The picture shows the dependencies within the modules of the cos-stack and the dependencies to the networking-stack.
![deps](_docs/module-dependencies.png)

## References

* [Nomad Terraform Module](https://github.com/hashicorp/terraform-aws-nomad)
* [Consul Terraform Module](https://github.com/hashicorp/terraform-aws-consul)
