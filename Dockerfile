FROM postgres:18.3-alpine AS extension-builder

COPY ./root /
RUN apk add --no-cache make clang19 clang19-libclang build-base git curl-dev perl libxml2-dev geos-dev proj-dev protobuf-c-dev gdal-dev json-c-dev llvm19 postgresql-plpython3 libcurl ca-certificates py3-pip libxml2 geos proj protobuf-c gdal json-c rust cargo flex bison readline-dev rustfmt
RUN ash /install.sh

FROM postgres:18.3-alpine

RUN apk add --no-cache geos proj protobuf-c json-c
COPY --from=extension-builder /usr/local/share/postgresql/extension /usr/local/share/postgresql/extension
COPY --from=extension-builder /usr/local/lib/postgresql /usr/local/lib/postgresql
