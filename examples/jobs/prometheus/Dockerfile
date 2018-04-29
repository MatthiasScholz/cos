FROM prom/prometheus
COPY prometheus.yml /etc/prometheus/prometheus.yml


CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
"--storage.tsdb.path=/prometheus", \
"--web.console.libraries=/usr/share/prometheus/console_libraries", \
"--web.console.templates=/usr/share/prometheus/consoles", \
"--web.external-url=/prometheus/" ]
