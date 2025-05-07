FROM postgres:17.4-alpine

COPY ./root /
RUN apk update && apk add make clang19 build-base git curl-dev perl libxml2-dev geos-dev proj-dev protobuf-c-dev gdal-dev json-c-dev llvm19 postgresql-plpython3 libcurl ca-certificates py3-pip libxml2 geos proj protobuf-c gdal json-c
RUN ash /install.sh
