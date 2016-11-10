echo "rsyslog server ip: "
read rsyslog_ip

cat << EOF > /etc/rsyslog.conf
\$ModLoad imuxsock # provides support for local system logging (e.g. via logger command)
\$ModLoad imjournal # provides access to the systemd journal
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
*.* @@$rsyslog_ip:514

systemctl restart rsyslog
