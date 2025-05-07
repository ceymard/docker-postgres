#!/bin/bash

set -e

PG_CRON_VERSION="1.6.5"
PGSQL_HTTP_VERSION="1.5.0"
POSTGIS_VERSION="3.5.1"
ENVVAR_VERSION="1.0.0"

cd /usr/local/share/postgresql/extension/
ln -sf /usr/share/postgresql/extension/plpython3u* .
cd /usr/local/lib/postgresql
ln -sf /usr/lib/postgresql/plpython* .
cd /

mkdir -p /build

cd /build
wget https://github.com/theory/pg-envvar/archive/refs/tags/v${ENVVAR_VERSION}.tar.gz
tar xf v$ENVVAR_VERSION.tar.gz
cd pg-envvar-$ENVVAR_VERSION
make && make install

cd /build
wget https://github.com/pramsey/pgsql-http/archive/v$PGSQL_HTTP_VERSION.tar.gz
tar xf v$PGSQL_HTTP_VERSION.tar.gz
cd pgsql-http-$PGSQL_HTTP_VERSION
make && make install

cd /build
git clone --depth 1 --branch v$PG_CRON_VERSION https://github.com/citusdata/pg_cron.git
cd pg_cron
sed -i 's/-Werror //g' Makefile
make && make install

wget https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz
tar xf postgis-$POSTGIS_VERSION.tar.gz
cd postgis-$POSTGIS_VERSION
./configure && make && make install


cd /
rm -rf /build
apk del build-base clang19 llvm19 git curl-dev perl libxml2-dev geos-dev proj-dev protobuf-c-dev gdal-dev json-c-dev make
rm -f /var/cache/apk/*
