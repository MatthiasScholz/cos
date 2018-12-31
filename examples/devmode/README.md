# COS Development Mode

## Development Mode - Simple
Local setup for development purposes. This will provide a local Docker registry and a local nomad running.

### Limitation: Localhost Only Access
In this configuration it will only be possible to use localhost and hence is inconvenient if one has to use the host ip address to interconnect services

-> Section: **Development Mode - Advanced**

### Quickstart
```
sudo nomad agent -dev -dc="testing"
# Note: Use a new terminal to preserve log output of the nomad agent.
export NOMAD_ADDR=http://localhost:4646
nomad run registry/creg.nomad
```
### Setup
Start nomad in dev mode and configure the datacenter to reflect the actual one once deployed.
* `sudo nomad agent -dev -dc="testing"` ( default dc: "dc1" )


## Development Mode - Advanced
For the setup of the advanced mode a specific nomad configuration file is provided: `dev.hcl`. This configuration provides a local server and client setup. And avoids and uses the host ip address to setup the client node.

To use the advanced mode just follow the instructions for the simple mode and replace `localhost` with `<host_ip_address>`.

NOTE: Remember not to check in your host specific configuration files!

### Quickstart
```
sudo nomad agent -config=dev.hcl
# Note: Use a new terminal to preserve log output of the nomad agent.
export NOMAD_ADDR=http://<host_ip_address>:4646
nomad run registry/creg.nomad
```

## Local Docker Registry
1. One time: Configure the Docker daemon to accept local Docker registry. Check the subsections for OS support.
2. Deploy a local Docker registry in the local nomad
   * `nomad run creg.nomad`
   
NOTE:
* Advanced mode: Replace `localhost` with your `<host_ip_address>`.

### Setup
#### Linux
1. Configuration have to be done at: `/etc/docker/daemon.json`:
```
{
    "insecure-registries" : [ "localhost:5000" ]
}

```
2. Restart the daemon.

#### MacOS
Using the "Docker Desktop" just check out the "Preferences/Daemon" section and add the local Docker registry `localhost:5000` at "Insecure registries".


### Usage
#### Pushing to Docker Registry
```
docker build -t samplejob .
docker tag samplejob:latest localhost:5000/samplejob:latest
docker push localhost:5000/samplejob:latest
```
##### Using with nomad
```
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
