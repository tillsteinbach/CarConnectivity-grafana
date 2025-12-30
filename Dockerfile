FROM grafana/grafana:12.3.1

ENV GF_LOG_LEVEL=info
ENV GF_SECURITY_ADMIN_USER=admin
ENV GF_SECURITY_ADMIN_PASSWORD=secret
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_PLUGINS_PREINSTALL_SYNC="frser-sqlite-datasource"
ENV GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=
ENV GF_PLUGINS_ENABLE_ALPHA=true
ENV GF_SERVER_ENABLE_GZIP=true
ENV SQLITE_DB_PATH="sqlite:////home/grafana/.carconnectivity/carconnectivity.db"
ENV GF_EXPLORE_ENABLED=false
ENV GF_ALERTING_ENABLED=false
ENV GF_METRICS_ENABLED=false
ENV GF_EXPRESSIONS_ENABLED=false
ENV GF_PLUGINS_PLUGIN_ADMIN_ENABLED=false
ENV GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH="/var/lib/grafana-static/dashboards/carconnectivity/CarConnectivity/overview.json"
ENV GF_FEATURE_TOGGLES_ENABLE="newPanelChromeUI,topNavCommandPalette"

COPY ./config/grafana/provisioning/ /etc/grafana/provisioning/
COPY ./dashboards/ /var/lib/grafana-static/dashboards/
COPY ./public/img/ /usr/share/grafana/public/img/

EXPOSE 3000
