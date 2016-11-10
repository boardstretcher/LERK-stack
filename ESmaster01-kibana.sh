#!/bin/bash
echo "IP address of this server: "
read ip_address

# Master 
yum install https://download.elastic.co/kibana/kibana/kibana-4.6.2-x86_64.rpm

cat << EOF > /etc/kibana/kibana.yml
server.port: 5601
server.host: "$ip_address"
server.name: "EScluster01"
elasticsearch.url: "http://$ip_address:9200"
kibana.index: ".kibana"
kibana.defaultAppId: "discover"
EOF

systemctl start kibana
systemctl enable kibana
systemctl status kibana

# http://localhost:5601/
