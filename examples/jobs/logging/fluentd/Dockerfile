# fluentd/Dockerfile
FROM fluent/fluentd:v1.0-onbuild
RUN ["gem", "install", "fluent-plugin-elasticsearch"]
RUN ["gem", "install", "fluent-plugin-grok-parser", "--no-rdoc", "--no-ri", "--version", "2.1.4"]
RUN ["gem", "install", "fluent-plugin-kv-parser", "--no-rdoc", "--no-ri", "--version", "1.0.0"]

EXPOSE 8002

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
