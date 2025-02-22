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
    && apt-get install -y apache2 mariadb-client cpanminus make cron \
    && rm -rf /var/lib/apt/lists/*


# FROM httpd:2.4-bookworm
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
RUN ln -s  /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/zzz_znuny.conf
RUN /usr/sbin/a2enmod perl headers deflate filter cgi
RUN a2dismod mpm_event
RUN /usr/sbin/a2enmod mpm_prefork
RUN a2enconf zzz_znuny
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN mkdir /opt/znuny/var/tmp

# RUN service apache2 restart

# ENTRYPOINT [ "su -c '/opt/znuny/bin/Cron.sh start ZNUNY_USER' root" ]

EXPOSE 80