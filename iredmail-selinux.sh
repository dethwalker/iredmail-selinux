#!/bin/bash


#ClamAV
echo "ClamAV..."
setsebool -P antivirus_can_scan_system 1
echo "Done!"

#dovecot
echo "dovecot..."
semanage port -a -t mail_port_t -p tcp 24242
semanage port -a -t mail_port_t -p tcp 12340
chcon -R -t mail_home_rw_t /var/vmail
semanage fcontext --add --type mail_home_rw_t --range s0 '/var/vmail(/.*)?'
echo "Done!"

#Nginx
echo "Nginx..."
setsebool -P httpd_can_network_connect 1
echo "Done!"

#Amavis
echo "Amavis..."
semanage port -m -t amavisd_recv_port_t -p tcp 10027
semanage port -m -t amavisd_recv_port_t -p tcp 10026
echo "Done!"

#fail2ban
echo "fail2ban..."
touch my-fail2ban.te


echo -e "module my-fail2ban 1.0;\n" >> my-fail2ban.te

echo "require {" >> my-fail2ban.te
echo -e "\ttype fail2ban_t;" >> my-fail2ban.te
echo -e "\ttype admin_home_t;" >> my-fail2ban.te
echo -e "\ttype mysqld_home_t;" >> my-fail2ban.te
echo -e "\ttype mysqld_port_t;" >> my-fail2ban.te
echo -e "\tclass file getattr;" >> my-fail2ban.te
echo -e "\tclass file { open read };" >> my-fail2ban.te
echo -e "\tclass tcp_socket name_connect;" >> my-fail2ban.te
echo -e "}\n" >> my-fail2ban.te

echo "#============= fail2ban_t ==============" >> my-fail2ban.te
echo "allow fail2ban_t admin_home_t:file getattr;" >> my-fail2ban.te
echo "allow fail2ban_t mysqld_home_t:file getattr;" >> my-fail2ban.te
echo "allow fail2ban_t admin_home_t:file { open read };" >> my-fail2ban.te
echo "allow fail2ban_t mysqld_port_t:tcp_socket name_connect;" >> my-fail2ban.te


checkmodule -M -m -o my-fail2ban.mod my-fail2ban.te
semodule_package -o my-fail2ban.pp -m my-fail2ban.mod
semodule -i my-fail2ban.pp

echo "Done!"

#netdata
echo "netdata..."
chcon -R -t var_log_t /opt/netdata/var/log/netdata
semanage fcontext -a -t var_log_t "/opt/netdata/var/log/netdata(/.*)?"
echo "Done!"

echo "All done!"
