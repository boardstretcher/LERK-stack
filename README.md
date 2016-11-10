# LERK-stack
Logstash+Elasticsearch+Rsyslog+Kibana

This installation is meant to have 5 servers. There are client files for linux (rsyslog_client) and windows (nxlog.conf).

You will need these servers:

* elasticsearch01 master + kibana
* elasticsearch02 slave
* elasticsearch03 slave
* logstash
* rsyslog

Do the installation in that order. Then connect your clients using rsyslog_client and nxlog. Rules are provided in logstash for syslog and windows event logs.
