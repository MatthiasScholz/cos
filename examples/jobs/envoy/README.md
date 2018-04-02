# Envoy Concepts

## Admin-Server

Each envoy-proxy instance contains an admin-server which provides statistics, logging and some configuration about the envox-proxy instance.

### Static Example

Admin-Server listens on port 8001 and writes no access logs.

```yaml
admin:
  access_log_path: "/dev/null"
  address:
    socket_address:
      address: 0.0.0.0
      port_value: 8001
```

## Listeners

A listener is a named network location (e.g., port, unix domain socket, etc.) that can accept connections from downstream clients (incoming traffic). Envoy exposes one or more listeners. Listener configuration can be declared statically in the bootstrap config, or dynamically via the listener discovery service (LDS).

1. Defines on which port to locally listen for a certain type traffic (i.e. http). All traffic of this type over the specified port will be intercepted by envoy.
2. Defines ```virtualhosts```, specifying which domains addressed over this port should be intercepted.

### Static Example

All ```http``` traffic over port ```80``` for all (```*```) domains will be intercepted.

```yaml
  listeners:
  - address:
      socket_address:
        address: 0.0.0.0
        port_value: 80
    filter_chains:
    - filters:
      - name: envoy.http_connection_manager
        config:
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
              - "*"
```

### LDS - Dynamic API (optional)

For dynamically changing the listener-configuration (instead of the static example above) you need to provide a service implementing the [LDS (Listener Discovery Service - API)](https://www.envoyproxy.io/docs/envoy/v1.6.0/configuration/listeners/lds.html). Having that, the listener-rules can be changed dynamically without the need to restart the envoy-proxy itself.

## Routes

A route is a set of rules that match ```virtual hosts``` to ```clusters``` and allow you to create traffic shifting rules. Routes are configured either via static definion, or via the route discovery service (RDS).

### Static Example

Traffic for all (```*```) domains will routed using path-based routing either to cluster ```service_1``` or ```service_1```.

```yaml
virtual_hosts:
- name: backend
  domains:
  - "*"
  routes:
  - match:
      prefix: "/service/1"
    route:
      cluster: service1
  - match:
      prefix: "/service/2"
    route:
      cluster: service2
```

### RDS - Dynamic API (optional)

For dynamically configuring the routes (instead of the static example above) you need to provide a service implementing the [RDS (Route Discovery Service - API)](https://www.envoyproxy.io/docs/envoy/v1.6.0/configuration/http_conn_man/rds.html). Having that, the routes can be changed dynamically without the need to restart the envoy-proxy itself.

## Clusters

A cluster is a group of similar upstream hosts (a named group of hosts/ports) that accept traffic from Envoy. Clusters allow for load balancing of homogenous service sets, and better infrastructure resiliency. You can configure timeouts, circuit breakers, discovery settings, and more on clusters.
Clusters are composed of endpoints – a set of network locations that can serve requests for the cluster. Clusters are configured either via static definitions, or by using the cluster discovery service (CDS).

### Static Example

Here two clusters are defined. Both use DNS-based routing over port 80.

```yaml
clusters:
- name: service1
  connect_timeout: 0.25s
  type: strict_dns
  lb_policy: round_robin
  http2_protocol_options: {}
  hosts:
  - socket_address:
      address: service1
      port_value: 80
- name: service2
  connect_timeout: 0.25s
  type: strict_dns
  lb_policy: round_robin
  http2_protocol_options: {}
  hosts:
  - socket_address:
      address: service2
      port_value: 80
```

### CDS - Dynamic API (optional)

For dynamically configuring and finding clusters (instead of the static example above) you need to provide a service implementing the [CDS (Cluster Discovery Service - API)](https://www.envoyproxy.io/docs/envoy/v1.6.0/configuration/cluster_manager/cds.html). Having that, new clusters can be added and existing ones can be configured without the need to restart the envoy-proxy itself.

## Endpoints

An endpoint is one upstream host (named group of host/port) that accept traffic from Envoy. They are defined as a group in a cluster. They can be configured statically or dynamically through EDS (endpoint discovery service). With EDS envoy will use service-discovery to dynamically find instances of the upstream services.

### Static Example

Here is one cluster are defined that has one statically defined endpoint named service1, reachable over port 80. To address the endpoint DNS is used.

```yaml
clusters:
- name: service1
  connect_timeout: 0.25s
  type: strict_dns
  lb_policy: round_robin
  http2_protocol_options: {}
  hosts:
  - socket_address:
      address: service1
      port_value: 80
```

### EDS - Dynamic API (optional)

For dynamically finding endpoints, thus using service-discovery instead of DNS you need to provide a service implementing the deprecated [SDS (Service Discovery Service - API)](https://www.envoyproxy.io/docs/envoy/latest/api-v1/cluster_manager/sds) or the newer [EDS (Endpoint Discovery Service - API)](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/eds.proto.html). Having that, new services that register/ deregister at the service-registry (i.e. consul) are added/ removed as envoy endpoints without the need to restart the envoy-proxy itself.

In the following example the cluster ```service-cluster``` is configured to dynamically find end points to route traffic to through EDS. Therfore the cluster ```service-cluster``` uses the a service implementing the [envoy v2 API](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api) using gPRC (```api_type: GPRC```) instead of the REST-API.

```yaml
clusters:
- name: service-cluster
  connect_timeout: 0.25s
  lb_policy: ROUND_ROBIN
  http2_protocol_options: {}
  type: EDS
  eds_cluster_config:
    eds_config:
      api_config_source:
        api_type: GRPC
        cluster_names: [xds_cluster]
- name: xds_cluster
  connect_timeout: 0.25s
  type: STATIC
  lb_policy: ROUND_ROBIN
  http2_protocol_options: {}
  hosts: [{ socket_address: { address: 127.0.0.1, port_value: 9000 }}]
```