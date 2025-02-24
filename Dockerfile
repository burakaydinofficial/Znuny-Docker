FROM alpine:3.14 AS alpine
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ='Europe/Istanbul'
COPY ./Docker/50-znuny_config.cnf /etc/mysql/mariadb.conf.d/50-znuny_config.cnf
COPY . /opt/znuny
RUN apk add --no-cache apache2 mariadb-client mariadb-server cpanminus make cron


FROM ubuntu:20.04 AS standalone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ='Europe/Istanbul'
COPY . /opt/znuny
RUN apt-get update \
    && apt-get install -y apache2 mariadb-client cpanminus make cpanminus make cron libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libauthen-sasl-perl libauthen-ntlm-perl libhash-merge-perl libical-parser-perl libspreadsheet-xlsx-perl libcrypt-jwt-perl libcrypt-openssl-x509-perl jq \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm install Jq

# To enable the Znuny Apache config you need to create a symlink to our sample config.
RUN ln -s  /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/zzz_znuny.conf

# Enable the needed Apache modules:
RUN /usr/sbin/a2enmod perl headers deflate filter cgi
RUN a2dismod mpm_event
RUN /usr/sbin/a2enmod mpm_prefork
RUN a2enconf zzz_znuny
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN mkdir /opt/znuny/var/tmp

RUN useradd -d /opt/otrs -c "Znuny user" -g www-data -s /bin/bash -M -N otrs

COPY Kernel/Config.pm.dist /opt/znuny/Kernel/Config.pm
RUN /opt/znuny/bin/znuny.SetPermissions.pl --znuny-user=otrs --web-group=www-data /opt/znuny

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# Follow http://hostname/znuny/installer.pl to install OTRS.


FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ='Europe/Istanbul'
COPY ./Docker/50-znuny_config.cnf /etc/mysql/mariadb.conf.d/50-znuny_config.cnf
COPY . /opt/znuny
# RUN apt-get update \
#     && apt-get install -y apache2 mariadb-client mariadb-server cpanminus make \
#     && rm -rf /var/lib/apt/lists/*
RUN apt-get update \
    && apt-get -y install apache2 mariadb-client mariadb-server cpanminus make cron libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl libmail-imapclient-perl libtemplate-perl libdatetime-perl libmoo-perl bash-completion libyaml-libyaml-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libauthen-sasl-perl libauthen-ntlm-perl libhash-merge-perl libical-parser-perl libspreadsheet-xlsx-perl libcrypt-jwt-perl libcrypt-openssl-x509-perl jq \
    && rm -rf /var/lib/apt/lists/*
RUN cpanm install Jq

# To enable the Znuny Apache config you need to create a symlink to our sample config.
RUN ln -s  /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/zzz_znuny.conf

# Enable the needed Apache modules:
RUN /usr/sbin/a2enmod perl headers deflate filter cgi
RUN a2dismod mpm_event
RUN /usr/sbin/a2enmod mpm_prefork
RUN a2enconf zzz_znuny
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN mkdir /opt/znuny/var/tmp

RUN useradd -d /opt/otrs -c "Znuny user" -g www-data -s /bin/bash -M -N otrs

COPY Kernel/Config.pm.dist /opt/znuny/Kernel/Config.pm
RUN /opt/znuny/bin/znuny.SetPermissions.pl --znuny-user=otrs --web-group=www-data /opt/znuny

# ENTRYPOINT [ "su -c '/opt/znuny/bin/Cron.sh start otrs' root" ]

# Create a mysql user for znuny
# RUN service mysql start & mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"

# Follow http://hostname/znuny/installer.pl to install OTRS.

EXPOSE 80
