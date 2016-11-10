#!/bin/bash

# configure rsyslog to receive syslogs and forward to logstash in JSON format
echo "Logstash server IP: "
read logstash_ip

cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

setenforce 0

yum -y update
yum -y install vim

cat << EOF > /etc/rsyslog.conf
\$ModLoad imuxsock
\$ModLoad imjournal
\$ModLoad imudp
\$UDPServerRun 514
\$ModLoad imtcp
\$InputTCPServerRun 514
\$WorkDirectory /var/lib/rsyslog
\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
\$IncludeConfig /etc/rsyslog.d/*.conf
\$OmitLocalLogging on
\$IMJournalStateFile imjournal.state
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
authpriv.*                                              /var/log/secure
mail.*                                                  -/var/log/maillog
cron.*                                                  /var/log/cron
*.emerg                                                 :omusrmsg:*
uucp,news.crit                                          /var/log/spooler
local7.*                                                /var/log/boot.log
# send all to /var/log/remote under hostname and program
\$template DEFAULT, "/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log" 
*.* ?DEFAULT
# remove any microsoft or windows related messages before forwarding to logstash
# nxlog takes care of sending to rsyslog AND logstash
:msg, contains, "Microsoft" ~
:msg, contains, "Desktop_Window_Manager" ~
# forward to logstash
*.* @@$logstash_ip:3511
EOF

systemctl restart rsyslog

sleep 5; rsyslogd -N1
