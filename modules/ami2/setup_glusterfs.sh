#!/bin/sh
set -e

SCRIPT=`basename "$0"`

MAJOR="4.0"
VERSION="${MAJOR}.1-1"
SUFIX="${VERSION}.el7.x86_64.rpm"
URL="http://buildlogs.centos.org/centos/7/storage/x86_64/gluster-${MAJOR}"

echo "[INFO] [${SCRIPT}] Installing glusterfs ${VERSION}"
sudo yum install -y                                        \
    ${URL}/glusterfs-api-${SUFIX}                          \
    ${URL}/glusterfs-cli-${SUFIX}                          \
    ${URL}/glusterfs-client-xlators-${SUFIX}               \
    ${URL}/glusterfs-extra-xlators-${SUFIX}                \
    ${URL}/glusterfs-fuse-${SUFIX}                         \
    ${URL}/glusterfs-libs-${SUFIX}                         \
    ${URL}/glusterfs-server-${SUFIX}                       \
    ${URL}/python-gluster-${GLUSTERVERSION}.el7.noarch.rpm \
    ${URL}/python2-gluster-${SUFIX}                        \
    ${URL}/glusterfs-${SUFIX}                              \
    ${URL}/glusterd2-4.0.0-1.el7.x86_64.rpm                \
    ${URL}/heketi-client-6.0.0-1.el7.x86_64.rpm            \
    ${URL}/heketi-6.0.0-1.el7.x86_64.rpm                   \
    ${URL}/heketi-templates-6.0.0-1.el7.x86_64.rpm         \
    ${URL}/userspace-rcu-0.10.0-3.el7.x86_64.rpm

echo "[INFO] [${SCRIPT}] Configuring init"
# Use GD1
sudo systemctl enable glusterd
# NOT WORKING:
# -> grpc: addrConn.resetTransport failed to create client transport: connection error: desc = "transport: dial tcp [fe80::8e6:1bff:fe9a:bf7e]:2379: connect: invalid argument"; Reconnecting to {[fe80::8e6:1bff:fe9a:bf7e]:2379 <nil>}
# Use the new GD2 - a redesigned GlusterFS
# NOT WORKING: sudo systemctl enable glusterd2
# DEBUG:
# NOT WORKING: sudo systemctl start  glusterd2
# NOT WORKING: sudo systemctl status glusterd2

echo "[INFO] [${SCRIPT}] Activating fuse"
sudo modprobe fuse
# DEBUG:
#echo "[DEBUG] [${SCRIPT}] modprobe.conf.d"
#ls  /etc/modprobe.d/


# FIXME: Bugfix because of an error in the heketi.service file
sudo curl https://github.com/heketi/heketi/blob/master/extras/systemd/heketi.service -o /usr/lib/systemd/system/heketi.service
