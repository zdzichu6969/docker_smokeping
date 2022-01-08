#!/bin/bash

export LC_ALL=""

[ -d /var/lib/smokeping/__cgi/ ] && echo "Directory '_cgi' exists, nothing to do." || mkdir -p /var/lib/smokeping/__cgi/; chown -R smokeping:smokeping /var/lib/smokeping
[ -d /var/run/smokeping/ ] && echo "Directory '/var/run/smokeping' exists, nothing to do." || mkdir -p /var/run/smokeping; chown -R smokeping:smokeping /var/run/smokeping

IP=$(/sbin/ip route | awk '/default/ { print $3 }')

if [ -f /etc/nginx/real_ip_docker.conf ]; then
   echo "Real IP configured. Nothing to do"
else
   echo "set_real_ip_from $IP/32;" > /etc/nginx/real_ip_docker.conf
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
