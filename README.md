# LERK-stack
Logstash+Elasticsearch+Rsyslog+Kibana

This installation is meant to have 5 servers. There are client files for linux (rsyslog_client) and windows (nxlog.conf).

You will need these servers:

* elasticsearch01 master + kibana
* elasticsearch02 slave
* elasticsearch03 slave
* logstash
* rsyslog

Do the installation in that order. Then connect your clients using rsyslog_client and nxlog. Rules are provided in logstash for syslog and windows event logs. Rsyslog will save a copy of all logs to /var/log/remote/%hostname%

Linux logs are sent to rsyslog and stored on disk and then forwarded to logstash. They are indexed in ES @ 'linux-hosts-%date%'

Windows logs are sent to rsyslog and stored on disk but not forwarded. There is a second route in nxlog to send directly to logstash. They are indexed in ES @ 'windows-hosts-%date%'
