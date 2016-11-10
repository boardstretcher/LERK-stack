#!/bin/bash

# create slave node 03

echo "ESnode01 ip: "
read ESnode01_ip
echo "ESnode02 ip: "
read ESnode02_ip
echo "ESnode03 ip: "
read ESnode03_ip

cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

cat << EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
$ESnode01_ip ESnode01
$ESnode02_ip ESnode02
$ESnode03_ip ESnode03
EOF

setenforce 0

echo "vm.max_map_count=262144" > /etc/sysctl.conf
sysctl -p

yum -y update
yum -y install java-1.8.0-openjdk.x86_64 vim
yum -y install https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.4.1/elasticsearch-2.4.1.rpm

# Slave 1
cat << EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: EScluster01
node.name: ESnode03
network.publish_host: $ESnode03_ip
network.host: $ESnode03_ip
path.data: /elasticsearch/data
path.logs: /elasticsearch/lost
node.master: false
transport.tcp.port: 9300
discovery.zen.ping.unicast.hosts: ["ESnode01:9300", "ESnode02", "ESnode03"]
EOF

mkdir -pv /elasticsearch/data
mkdir -pv /elasticsearch/logs
chown -R elasticsearch:elasticsearch /elasticsearch

systemctl start elasticsearch
systemctl enable elasticsearch
systemctl status elasticsearch

# elastic/changeme
sleep 15; curl -XGET 'http://ESnode03:9200/_cluster/state?pretty'
