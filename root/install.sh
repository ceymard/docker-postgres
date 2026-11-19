#!/bin/bash

set -e

PG_CRON_VERSION="1.6.8"
PGSQL_HTTP_VERSION="1.7.2"
POSTGIS_VERSION="3.7.0"
ENVVAR_VERSION="1.0.1"
PG_JSONSCHEMA_VERSION="0.3.4"
POSTCBOR_VERSION="0.1.0"
PLJS_VERSION="1.0.5"

mkdir -p /build

cd /build
wget https://github.com/theory/pg-envvar/archive/refs/tags/v${ENVVAR_VERSION}.tar.gz
tar xf v$ENVVAR_VERSION.tar.gz
cd pg-envvar-$ENVVAR_VERSION
make
make install

cd /build
wget https://github.com/pramsey/pgsql-http/archive/v$PGSQL_HTTP_VERSION.tar.gz
tar xf v$PGSQL_HTTP_VERSION.tar.gz
cd pgsql-http-$PGSQL_HTTP_VERSION
make
make install

cd /build
git clone --depth 1 --branch v$PG_CRON_VERSION https://github.com/citusdata/pg_cron.git
cd pg_cron
sed -i 's/-Werror //g' Makefile
make
make install

cd /build
# QuickJS is a git submodule, missing from release tarballs.
git clone --depth 1 --branch v$PLJS_VERSION --recurse-submodules --shallow-submodules https://github.com/plv8/pljs.git
cd pljs
# pljs links QuickJS statically into its shared library, which needs position-independent code.
CFLAGS=-fPIC make -C deps/quickjs libquickjs.a
make
make install

cd /build
wget https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz
tar xf postgis-$POSTGIS_VERSION.tar.gz
cd postgis-$POSTGIS_VERSION
./configure
make
make install

cd /build
wget https://github.com/supabase/pg_jsonschema/archive/refs/tags/v${PG_JSONSCHEMA_VERSION}.tar.gz
tar xf v$PG_JSONSCHEMA_VERSION.tar.gz
cd pg_jsonschema-$PG_JSONSCHEMA_VERSION

# pg_jsonschema and postcbor pin different pgrx versions, and cargo-pgrx must match
# the crate's pgrx exactly, so each gets its own cargo-pgrx install.
cargo install cargo-pgrx --version 0.16.1 --locked --root /opt/pgrx-0.16.1
export PGRX_HOME=/pgrx-0.16.1
PATH=/opt/pgrx-0.16.1/bin:$PATH cargo pgrx init --pg18 $(which pg_config)
PATH=/opt/pgrx-0.16.1/bin:$PATH cargo pgrx install --release
unset PGRX_HOME

cd /build
wget -O postcbor-v$POSTCBOR_VERSION.tar.gz https://github.com/ceymard/postcbor/archive/refs/tags/v${POSTCBOR_VERSION}.tar.gz
tar xf postcbor-v$POSTCBOR_VERSION.tar.gz
cd postcbor-$POSTCBOR_VERSION
# Install the toolchain pinned by postcbor's rust-toolchain.toml.
rustup toolchain install
cargo install cargo-pgrx --version 0.20.0 --locked --root /opt/pgrx-0.20.0
PATH=/opt/pgrx-0.20.0/bin:$PATH make install
