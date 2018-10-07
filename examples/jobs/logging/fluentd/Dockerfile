# fluentd/Dockerfile
FROM fluent/fluentd:v1.2-onbuild

RUN apk add --update --virtual .build-deps \
  sudo build-base ruby-dev \
  && sudo gem install --no-rdoc --no-ri\
  fluent-plugin-elasticsearch \
  fluent-plugin-grok-parser:2.1.4 \
  fluent-plugin-kv-parser:1.0.0 \
  fluent-plugin-prometheus:0.4.0 \
  && sudo gem sources --clear-all \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/* \
  /home/fluent/.gem/ruby/2.4.0/cache/*.gem

EXPOSE 8002

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
