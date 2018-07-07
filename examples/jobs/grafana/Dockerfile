FROM grafana/grafana

COPY datasources.yaml      /etc/grafana/provisioning/datasources/
COPY dashboard_config.yaml /etc/grafana/provisioning/dashboards/
COPY dashboard_cos.json    /var/lib/grafana/dashboards/

#################################################
# NOTE: The following lines can keep untouched. #
#################################################
ARG   VERSION=unknown
LABEL version=$VERSION
COPY  version /IMAGE_VERSION
