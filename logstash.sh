#!/bin/bash

echo "this servers ip?: "
read serverip
echo "elastic search ip?: "
read elasticip

cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

setenforce 0

yum -y update
yum -y install vim java-1.8.0-openjdk
yum -y install https://download.elastic.co/logstash/logstash/packages/centos/logstash-2.4.0.noarch.rpm

cat << EOF > /etc/logstash/conf.d/logstash.conf
input {
  # local rsyslog
  udp {
    type => "rsyslog"
    host => "127.0.0.1"
    port => 3510
  }

  # remote rsyslog
  tcp {
    type => "rsyslog"
    host => "$serverip"
    port => 3511
  }

  # remote windows eventlog
  tcp {
    type => "eventlog"
    codec => "json"
    host => "$serverip"
    port => 3512
  }
}

filter {
  if [type] == "rsyslog" {
    syslog_pri { }
    grok {
      match => [ "message", '\<%{NUMBER}\>%{SYSLOGTIMESTAMP:event_timestamp} %{DATA:hostname} %{GREEDYDATA}' ]
    } 
    mutate {
      add_field => { "system_os" => "linux" }
      remove_field => [ "host" ]
      remove_field => [ "port" ]
      gsub => [ "message", "^<[0-9]*>", "" ]
    }
  }
  if [type] == "eventlog" {
    mutate {
      add_field => { "system_os" => "windows" }
      remove_field => [ "port" ]
      remove_field => [ "SourceModuleName" ]
      remove_field => [ "SourceModuleType" ]
    }
  }
}

output {
  # debugging to file
  #file {
  #  path => [ "/var/log/logstash_input" ]
  #}
  # further debugging
  #stdout { 
  #  codec => rubydebug 
  #}

  if [type] == "rsyslog" {
    elasticsearch {
      hosts => [ "$elasticip:9200" ]
      index => "linux-hosts-%{+YYYY.MM.dd}"
    }
  }

  if [type] == "eventlog" {
    elasticsearch {
      hosts => [ "$elasticip:9200" ]
      index => "windows-hosts-%{+YYYY.MM.dd}"
    } 
  }
}
EOF
