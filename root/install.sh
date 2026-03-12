#!/bin/bash

set -e

PG_CRON_VERSION="1.6.7"
PGSQL_HTTP_VERSION="1.7.0"
POSTGIS_VERSION="3.6.2"
ENVVAR_VERSION="1.0.1"
PG_JSONSCHEMA_VERSION="0.3.4"

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

cd /build
wget https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz
tar xf postgis-$POSTGIS_VERSION.tar.gz
cd postgis-$POSTGIS_VERSION
./configure && make && make install

cd /build
wget https://github.com/supabase/pg_jsonschema/archive/refs/tags/v${PG_JSONSCHEMA_VERSION}.tar.gz
tar xf v$PG_JSONSCHEMA_VERSION.tar.gz
cd pg_jsonschema-$PG_JSONSCHEMA_VERSION

mkdir /pgrx
export PGRX_HOME=/pgrx
cargo install cargo-pgrx --version 0.16.1 --locked
cargo pgrx init --pg18 $(which pg_config)

cargo pgrx install
