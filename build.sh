#!/bin/sh
set -e

#update and install dependencies
apt-get update
apt-get install -y git wget build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev

#make modsecurity
cd /usr/src/
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity.git /usr/src/modsecurity
cd /usr/src/modsecurity
git submodule init
git submodule update
./build.sh
./configure
make
make install

#libmodsecurity with nginx
cd /root 
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

#make nginx
cd /
wget http://nginx.org/download/nginx-1.14.0.tar.gz
tar xvzf nginx-1.14.0.tar.gz
cd nginx-1.14.0
./configure --user=root --group=root --with-debug --with-ipv6 --with-http_ssl_module --add-module=/root/ModSecurity-nginx --with-http_ssl_module --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_empty_gif_module --without-http_fastcgi_module --without-http_referer_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module
make
make install

#configure env
ln -s /usr/local/nginx/sbin/nginx /bin/nginx
mkdir -p /opt/modsecurity/var/audit/
cp /usr/src/modsecurity/unicode.mapping /usr/local/nginx/conf/

#install signature
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs
cp -R /usr/src/owasp-modsecurity-crs/rules/ /usr/local/nginx/conf/
mv /usr/local/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf{.example,}
mv /usr/local/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf{.example,}

apt-get purge -y build-essential wget git
rm /nginx-1.14.0.tar.gz
