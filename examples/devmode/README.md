# COS Development Mode

## Development Mode - Simple

Local setup for development purposes.
This will provide a local Docker registry and a local nomad running.

### Limitation: Localhost Only Access

In this configuration it will only be possible to use localhost and
hence is inconvenient if one has to use the host ip address to interconnect services.

-> Section: **Development Mode - Advanced**

### Quickstart

```bash
sudo nomad agent -dev -dc="testing"
# Note: Use a new terminal to preserve log output of the nomad agent.
export NOMAD_ADDR=http://localhost:4646
nomad run registry/creg.nomad
```

### Setup

Start nomad in dev mode and configure the datacenter
to reflect the actual one once deployed.

* `sudo nomad agent -dev -dc="testing"` ( default dc: "dc1" )

## Development Mode - Advanced

For the setup of the advanced mode a specific nomad configuration file
is provided: `nomad.hcl`. This configuration provides a local server and
client setup. And avoids and uses the host ip address to setup the client node.
Furthermore a local setup for consul is provided with the `consul.hcl`.
This will allow the interaction with the service discovery and
the load balancer ( fabio ).

To use the advanced mode just follow the instructions for the simple mode and
replace `localhost` with `<host_ip_address>`.
The `<host_ip_address>` has to be configured in the `nomad.hcl` and
in the `consul.hcl` by replacing the `<host_ip_address>` place holder.

### NOTE

Remember: Do NOT check in your host specific configuration files!

### Quickstart

```bash
consul agent -config-file=consul.hcl
sudo nomad agent -config=nomad.hcl
# Note: Use a new terminal to preserve log output of the nomad agent.
export NOMAD_ADDR=http://<host_ip_address>:4646
nomad run registry/creg.nomad
```

Or call the `devmode.sh` script:

```bash
# generic call
# ./devmode.sh <host_ip_address> [<name of datacenter>]

# start devmode with consul and nomad using datacenter named "testing"
./devmode.sh 192.168.1.10

# start devmode with consul and nomad using datacenter named "my-datacenter-name"
./devmode.sh 192.168.1.10 my-datacenter-name
```

### Service Discovery

#### Quickstart

```bash
consul agent -dev -node local -> not working with fabio!
```

#### Local Consul

The nomad agent configuration has to be adapted in order to support
automatic service registration in Consul.
To make this work the `<host_ip_address>` in the `nomad.hcl`
has to be updated to match your current setup.

#### Fabio

Fabio just works out of the box. No additional adjustments are needed
if fabio is used natively with the nomad `exec` driver.

##### Docker

For Fabio running in a Docker container again the `<host_ip_address>`
has to be configured. This time in the `fabio_docker.nomad` job description.

## Local Docker Registry

1. One time: Configure the Docker daemon to accept local Docker registry.
   Check the subsections for OS support.
1. Deploy a local Docker registry in the local nomad
  * `nomad run registry/creg.nomad`

### NOTE

* Advanced mode: Replace `localhost` with your `<host_ip_address>`.

### Setup

#### Linux

1. Configuration have to be done at: `/etc/docker/daemon.json`:

   ```json
   {
     "insecure-registries" : [ "localhost:5000" ]
   }
   ```
1. Restart the daemon.

#### MacOS

Using the "Docker Desktop" just check out the "Preferences/Daemon" section and
add the local Docker registry `localhost:5000` at "Insecure registries".

### Usage

#### Pushing to Docker Registry

```bash
docker build -t samplejob .
docker tag samplejob:latest localhost:5000/samplejob:latest
docker push localhost:5000/samplejob:latest
```

##### Using with nomad

```hcl
job "samplejob" {
  datacenters = [ "testing" ]
  ...

  group "server" {
    count = 1

    task "registry" {
      driver = "docker"

      config {
        image = "localhost:5000/samplejob:latest"
        ...
      }
    }
  }
}

```
