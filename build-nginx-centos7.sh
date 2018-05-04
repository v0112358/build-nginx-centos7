#!/bin/bash
# Build Nginx + Lua module
# This script is tested on CentOS 7.3

# install dependentcy packages
yum -y install gcc gcc-c++ patch expat-devel pcre-devel zlib-devel autoconf libaio libaio-devel gcc44 gcc44-c++ libstdc++44-devel freetype-devel openssl-devel curl* icu* libicu-devel libxslt* libmcrypt* libXpm-devel readline-devel bzip* openldap openldap-devel libc-client-devel libtidy libtidy-devel libmhash-devel aspell-devel pcre-devel libjpeg-devel libpng-devel libcurl4-gnutls-devel libpng12-devel libfreetype6-devel libmcrypt-devel libxslt-devel libcurl libcurl-devel wget make
yum install libxml2 pcre-devel curl-devel perl-devel perl-ExtUtils-Embed lua-devel GeoIP-devel git -y

# Download source code
cd /usr/local/src
git clone https://github.com/openresty/lua-nginx-module
wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz
tar xzvf ngx_cache_purge-2.3.tar.gz

wget http://nginx.org/download/nginx-1.14.0.tar.gz
tar xzvf nginx-1.14.0.tar.gz
cd nginx-1.14.0

# Build Nginx
sed -i 's/Server: nginx/Server: LuaSRV/g' src/http/ngx_http_header_filter_module.c
sed -i 's/nginx\//LuaSRV\//g' ./src/core/nginx.h
sed -i 's/"<hr><center>nginx<\/center>" CRLF/"<hr><center>LuaSRV<\/center>" CRLF/g' src/http/ngx_http_special_response.c
./configure --sbin-path=/usr/local/sbin --conf-path=/etc/nginx/nginx.conf --http-fastcgi-temp-path=/tmp/nginx_fastcgi --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --add-module=../ngx_cache_purge-2.3 --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-debug --with-http_mp4_module --with-http_gzip_static_module --with-http_realip_module --user=nginx --group=nginx --with-http_ssl_module --add-module=../lua-nginx-module
make && make install

# Download sample configure and systemd unit file
useradd -s /sbin/nologin -d /var/www/html nginx
wget -O /etc/logrotate.d/nginx 
wget -O /etc/systemd/system/nginx.service
systemctl daemon-reload
systemctl enable nginx
