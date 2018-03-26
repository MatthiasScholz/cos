# Overview
* [ ] TODO: Explaining the available AMIs.

# Amazon Linux 2
* Nomad
* Consul
* Docker
* AWS ECR plugin
* privileged mode activated

# GlusterFS

## Configure AWS
* [Terraform EBS Volume](https://stackoverflow.com/questions/42610807/terraform-ebs-volume)
* [EBS Volume](https://www.packer.io/docs/builders/amazon-ebsvolume.html)

### Terraform: nomad-cluster
```hcl
# terraform-aws/module/nomad-cluster/main.tf
resource "aws_launch_configuration" "launch_configuration" {
  # ...

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 10
    volume_type = "gp2"
  }

  # ...
}
```

## GlusterFS Setup
0. `sudo su -`
1. Prepare file system
   * https://yogeshmaloo.wordpress.com/2015/01/18/installation-and-configuration-of-glusterfs-filesystem-on-amazon-linux-ec2-instances/
   * `../nomad/user-data-nomad-client.sh`
2. Install glusterfs - https://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/
   * `./setup_glusterfs.sh`
3. Start glusterd2
   * At instance startup due to configuration in `./setup_glusterfs.sh`.
4. Configure Trusted Pool
   * `consul catalog nodes -service=nomad-client`
   * `sudo gluster peer status`
   * `sudo gluster peer probe <nomad_client1_IP>`
   * `... add more peers ...`
   * `sudo gluster peer status`
5. Setup Volume
   * Folder: `sudo mkdir -p /data/glusterfs/test-brick/`
      * Usually this has to be done on every nomad_client ( already preconfiged during terraforming )!
   * Permission for Docker: `sudo chmod a+w -R /data/glusterfs/test-brick/`
      * * Usually this has to be done on every nomad_client ( already preconfiged )!
   * Create: `sudo gluster volume create test-brick <nomad_client1_IP>:/data/glusterfs/test-brick ...`
   * Start:  `sudo gluster volume start test-brick`
   * State:  `sudo gluster volume info test-brick`
   * => might be better to use something like [heketi](https://github.com/heketi/heketi) for the cluster management.

### Service Discovery
Every nomad client will be a server and a client for glusterfs. This way the client finds very easily a server.
But nevertheless the server needs to be joined - How to connect to the other GlusterFS server instances?
* [ ] TODO: Check [Heketi for Volume Management](https://github.com/heketi/heketi) - needs raw devices ( currently they are xfs formated - user-data-script )
* [ ] TODO: [ServiceDiscovery](https://docs.gluster.org/en/latest/Administrator%20Guide/Consul/)

#### Consul
First shot could be an automated nomad batch job using:
* List all available gluster server: `consul catalog nodes -service=nomad-client`

### Metrics
* [Section: Monitoring Support](https://docs.gluster.org/en/latest/release-notes/4.0.0/)
  * https://github.com/amarts/glustermetrics

Currently core gluster stack and memory management systems provide metrics.

### GD2 - NOT WORKING
Currently  ( 2018-03-26 ) there seems to be an stability issue or a AWS configuration issue after connecting the peers etcd stopped working. Service restart did not solve the issue.

#### Configuration
* `sudo systemctl disable glusterd && sudo systemctl stop glusterd`
* `sudo systemctl disable glusterd2 && sudo systemctl stop glusterd2`
* `sudo glustercli peer status`
* `sudo glustercli peer probe <nomad_client1_IP>`

#### Notes
* GD2 uses *etcd* to store the Gluster pool configuration
* GD2 does not work well in 2-node clusters.
  * It is recommended right now to run GD2 only in clusters of 3 or larger.

## GlusterFS Client
* [Native Client & NFS](https://docs.gluster.org/en/latest/Administrator%20Guide/Setting%20Up%20Clients/#gluster-native-client)

* `mount -t glusterfs <HOSTNAME-OR-IPADDRESS>:/<VOLNAME MOUNTDIR>`
