FROM debian:11-slim
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Warsaw /etc/localtime && echo 'Europe/Warsaw' > /etc/timezone

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt upgrade -o APT::Install-Suggests=0 --no-install-recommends -y

RUN apt install -o APT::Install-Suggests=0 --no-install-recommends -y \
       curl perl libwww-perl libsnmp-session-perl librrds-perl liburi-perl fping libcgi-fast-perl debianutils \
       adduser lsb-base libdigest-hmac-perl ucf libconfig-grammar-perl libjs-cropper libjs-scriptaculous libjs-prototype \
       libsocket6-perl libauthen-radius-perl libnet-ldap-perl sendmail libio-socket-ssl-perl libnet-telnet-perl \
       fcgiwrap nano supervisor cron iproute2

# NGINX
RUN apt install -o APT::Install-Suggests=0 --no-install-recommends -y \
       ca-certificates gnupg2 ca-certificates lsb-release
RUN echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt update && apt install -o APT::Install-Suggests=0 --no-install-recommends -y nginx
RUN mkdir -p /etc/nginx/sites-enabled/ /var/www/ /var/log/nginx/
## NGINX END

#RUN  rm /etc/nginx/sites*/* && rm /etc/nginx/nginx.conf ## OFF bo nowy nginx (nie z repo)
COPY smokeping_2.8.2-1_all.deb /tmp/smokeping_2.8.2-1_all.deb
COPY docker/fcgiwrap.conf /etc/nginx/
COPY docker/default.conf /etc/nginx/sites-enabled/default.conf
COPY docker/nginx.conf /etc/nginx/nginx.conf

#RUN  ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN  cd /tmp/; dpkg -i smokeping_2.8.2-1_all.deb
RUN  ln -s /usr/share/smokeping/www /var/www/smokeping
RUN  ln -s /usr/lib/cgi-bin/smokeping.cgi /usr/share/smokeping/www/smokeping.cgi
RUN  echo '<meta http-equiv="refresh" content="0; url=/smokeping/smokeping.cgi" />' > /var/www/index.html
RUN  echo "30 4 * * * : > /var/log/nginx/access.log; : > /var/log/nginx/error.log" >> /var/spool/cron/crontabs/root

RUN  apt-get clean -y && apt-get -y autoremove
RUN  rm /tmp/*

COPY docker/start.sh /
COPY docker/supervisor_smokeping.conf /etc/supervisor/conf.d/
RUN  chmod +x /start.sh

EXPOSE 80
ENTRYPOINT [ "/start.sh" ]
