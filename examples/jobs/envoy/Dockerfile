################### BUILDER IMAGE ################################
FROM golang:alpine AS builder

# install git
RUN set -ex &&\
apk update &&\
apk add --no-cache git &&\
apk add --no-cache glide &&\
apk add --no-cache make


# copy ping_service files and build the ping_service
COPY ./consul-envoy-xds /go/src/consul-envoy-xds
WORKDIR /go/src/consul-envoy-xds
RUN make setup
RUN make build
RUN make install


###
FROM envoyproxy/envoy:latest
COPY --from=builder /go/bin/consul-envoy-xds /bin/consul-envoy-xds
COPY --from=builder /go/src/consul-envoy-xds/application.yml.sample /etc/envoy/application.yml

RUN apt-get update && apt-get install -y musl
COPY envoy.yaml /etc/envoy/envoy.yaml
CMD envoy --v2-config-only -c /etc/envoy.yaml --service-cluster local_service_cluster --service-node local_service_node

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
