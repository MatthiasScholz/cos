# Sgrules Module

In this module the security groups of nomdad-clients, -server and consul-nodes are connected apropriately to ensure that the minimal needed access between the instances is ensured.

## Overview

![sg-rules instances](../../_docs/sg_instances.png)

## Sgrules between Nomad Servers and Clients

![sg-rules instances](../../_docs/sg_nomad_client_and_server.png)

## Sgrules between Consul and Nomad Instances

![sg-rules instances](../../_docs/sg_consul_and_nomad.png)

## Sgrules between UI-ALB and Nomad, Consul Instances

![sg-rules instances](../../_docs/sg_ui_alb.png)