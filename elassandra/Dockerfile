ARG BASE_IMAGE
ARG THIRD_PARTY_SOURCES_DIR=/usr/share/cassandra/third-party-sources

FROM debian:stretch-slim as builder
ARG THIRD_PARTY_SOURCES_DIR
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget unzip tar && rm -rf /var/lib/apt/lists/*
COPY elassandra/download-sources.sh /
COPY elassandra/sources-url.csv /
RUN mkdir -p ${THIRD_PARTY_SOURCES_DIR} && \
    cd ${THIRD_PARTY_SOURCES_DIR} && \
    cat /sources-url.csv | /download-sources.sh

FROM ${BASE_IMAGE}
ARG THIRD_PARTY_SOURCES_DIR
COPY --from=builder ${THIRD_PARTY_SOURCES_DIR} ${THIRD_PARTY_SOURCES_DIR}
