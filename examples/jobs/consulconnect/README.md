# Usage Example: Consul Connect - NOT WORKING

This folder provides an example on how to use Consul Connect in the cluster.
It is derived from the this [tutorial](https://www.hashicorp.com/blog/consul-connect-integration-in-hashicorp-nomad/).

## !!! Errors !!!

Image: https://console.cloud.google.com/gcr/images/google-containers/GLOBAL/pause-amd64@sha256:163ac025575b775d1c0f9bf0bdd0f086883171eb475b5068e7defa4ca9e76516/details?tab=info

Local Pull Working:
- `docker pull gcr.io/google-containers/pause-amd64:3.0`

"""
failed to setup alloc:
 pre-run hook "network" failed:
  failed to create network for alloc:
   Failed to pull `gcr.io/google_containers/pause-amd64:3.0`:
    API error (500):
     Get https://gcr.io/v2/: -> Google Container Registry
      net/http:
       request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
"""

### State of Investigation

Reason currently unclear. Further debugging necessary.

Checked:
- docker.config - ecr helper only limited to amazon,
  -> all other Docker registries should be supported as well.
- Security Group Configuration - outbound traffic for nodes in private datacenter fully open

## Usage

This usage example was tested with `examples/root-example/README.md`.

- `nomad run api_service.nomad`
- `nomad run dashboard_service.nomad`

- `curl ???`

### Prerequisits

- consul >=1.6
- CNI plugins installed on the instance

### Limitations
- [Consul Connect Native](https://www.consul.io/docs/connect/native.html) is not yet supported.
  - -> Integration into the application without sidecar not usable.
- Consul Connect HTTP and gRPC checks are not yet supported.
  - -> No [health check](https://www.consul.io/docs/agent/checks.html) support.
  - -> __Fabio usage unclear__.
- [Consul ACLs](https://learn.hashicorp.com/consul/security-networking/production-acls) are not yet supported.
  - -> No additional access management only network separation.
- __Variable interpolation for group services and checks are not yet supported.__ ???

## Background

- envoy via [Docker](https://hub.docker.com/r/envoyproxy/envoy)

> Hashicorp:
> Prior to Nomad 0.10, Nomad’s networking model running all applications in _host networking mode_.
> Applications running on the same host could communicate with each other over localhost!
>
> Nomad 0.10 introduces network namespace support.
> This is a new network model within Nomad
> where task groups are a single network endpoint and
> share a network namespace.

### Job Specification

- `connect`
- `sidecar_service`

#### network stanza - New Networking Modes

- _none_
  - isolated network without any network interfaces
- ___bridge__
  - isolated network namespace with an interface that is bridged with the host
- _host_
  - join the host network namespace and a shared network namespace is not created.
  - _This matches the behavior in Nomad 0.9_
