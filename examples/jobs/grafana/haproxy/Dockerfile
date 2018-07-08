FROM haproxy:1.8.9-alpine
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
