echo "rsyslog server ip: "
read rsyslog_ip

cat << EOF > /etc/rsyslog.conf
\$ModLoad imuxsock
\$ModLoad imjournal
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

# local ossec log
$InputFileName /var/log/ossec/ossec.log
$InputFileTag ossec
$InputFileStateFile ossec
$InputFileReadMode 1
$InputFileSeverity info
$InputFileFacility local7
$InputRunFileMonitor
$InputFilePollInterval 10
if $programname == 'ossec' then @@$rsyslog_ip:514
*.* @@$rsyslog_ip:514

EOF

systemctl restart rsyslog
