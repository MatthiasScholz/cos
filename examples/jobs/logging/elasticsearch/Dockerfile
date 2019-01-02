FROM docker.elastic.co/elasticsearch/elasticsearch-oss:6.5.4

COPY elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
