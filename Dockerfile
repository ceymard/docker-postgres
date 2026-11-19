FROM postgres:18.7-alpine3.24 AS extension-builder

COPY ./root /
RUN apk add --no-cache make clang21 clang21-libclang build-base git curl-dev perl libxml2-dev geos-dev proj-dev protobuf-c-dev gdal-dev json-c-dev llvm21 libcurl ca-certificates py3-pip libxml2 geos proj protobuf-c gdal json-c rustup flex bison readline-dev icu-dev gmp-dev
# rustup's musl toolchains link statically by default (Alpine's rust package does not); extensions loaded by
# postgres must link musl dynamically.
ENV RUSTUP_HOME=/rustup CARGO_HOME=/cargo PATH=/cargo/bin:$PATH RUSTFLAGS="-C target-feature=-crt-static"
RUN rustup-init -y --no-modify-path --profile minimal --default-toolchain stable
RUN ash /install.sh

FROM postgres:18.7-alpine3.24

RUN apk add --no-cache geos proj protobuf-c json-c gmp
COPY ./root/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
COPY --from=extension-builder /usr/local/share/postgresql/extension /usr/local/share/postgresql/extension
COPY --from=extension-builder /usr/local/lib/postgresql /usr/local/lib/postgresql
