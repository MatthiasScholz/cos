# Upgrade

Contains information on how to update the versions used in this repository.

## References to latest version

- [nomad](https://www.nomadproject.io/downloads)
- [consul](https://www.consul.io/downloads)
- [terraform: consul module](https://github.com/hashicorp/terraform-aws-consul/releases)
- [terraform: nomad module](https://github.com/hashicorp/terraform-aws-nomad/releases)
- [CNI Plugins](https://github.com/containernetworking/plugins/releases)
- [fabio](https://github.com/fabiolb/fabio/releases)

## Infrastructure

### AMI

- [ECR + CNI](..modules/ami2/nomad-consul-docker-ecr-cni.json)
- [ECR](../modules/ami2/nomad-consul-docker-ecr.json)
- [Plain](../modules/ami2/nomad-consul-docker.json)

### Ingress

Since Fabio is used as a job within the cluster the job description needs to be updated:
- [fabio job](../examples/jobs/fabio.nomad)

### Terraform

#### Consul

- [consul-cluster](../modules/consul/main.tf)
- [consul-iam-policies](../modules/nomad/servers.tf)

#### Nomad

- [nomad-cluster](../modules/nomad/servers.tf)

#### Nomad Datacenter

- [nomad-datacenter](../modules/nomad-datacenter/datacenter.tf)
- [consul-iam-policies](../modules/nomad-datacenter/datacenter.tf)

## Tests

- [nomad](../test/Makefile)
- [terratest](../test/Makefile)

