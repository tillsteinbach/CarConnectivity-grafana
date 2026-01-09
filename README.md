# Grafana provisioned for CarConnectivity Software
[![GitHub sourcecode](https://img.shields.io/badge/Source-GitHub-green)](https://github.com/tillsteinbach/CarConnectivity-grafana/)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/tillsteinbach/CarConnectivity-grafana)](https://github.com/tillsteinbach/CarConnectivity-grafana/releases/latest)
[![GitHub](https://img.shields.io/github/license/tillsteinbach/CarConnectivity-grafana)](https://github.com/tillsteinbach/CarConnectivity-grafana/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/tillsteinbach/CarConnectivity-grafana)](https://github.com/tillsteinbach/CarConnectivity-grafana/issues)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/tillsteinbach/carconnectivity-grafana?sort=semver)](https://hub.docker.com/r/tillsteinbach/carconnectivity-grafana)
[![Docker Pulls](https://img.shields.io/docker/pulls/tillsteinbach/carconnectivity-grafana)](https://hub.docker.com/r/tillsteinbach/carconnectivity-grafana)
[![Donate at PayPal](https://img.shields.io/badge/Donate-PayPal-2997d8)](https://www.paypal.com/donate?hosted_button_id=2BVFF5GJ9SXAJ)
[![Sponsor at Github](https://img.shields.io/badge/Sponsor-GitHub-28a745)](https://github.com/sponsors/tillsteinbach)

This image provisions Grafana with the following:
- Datasource to connect to PostgreSQL database with data from the car (Works with [CarConnectivity-plugin-database](https://github.com/tillsteinbach/CarConnectivity-plugin-database))
- Datasource to obtain live data from the vehicle through CarConnectivity WebUI (Works with [CarConnectivity-plugin-webui](https://github.com/tillsteinbach/CarConnectivity-plugin-webui))
- Dashboards visualizing the data

## More information
More information can be found on Github: https://github.com/tillsteinbach/CarConnectivity-grafana/


## Requirements
* Docker 20.10.10 or later (if you are new to Docker, see [Installing Docker and Docker Compose](https://docs.docker.com/engine/install/) or for [Raspberry Pi](https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl)), docker-compose needs to be at least version 1.27.0 (you can check with `docker compose --version`)
* A Machine that's always on, so VWsFriend can continually fetch data
* External internet access, to talk to the servers

## How to start
* Clone or download the files [docker-compose.yml](https://raw.githubusercontent.com/tillsteinbach/CarConnectivity-grafana/main/docker-compose.yml) and [.env](https://raw.githubusercontent.com/tillsteinbach/CarConnectivity-grafana/main/.env)
* To create myconfig.env copy [.env](https://raw.githubusercontent.com/tillsteinbach/CarConnectivity-grafana/main/.env) file and make changes according to your needs
* create your carconnectivity.json configuration file as described in the [CarConnectivity repository](https://github.com/tillsteinbach/CarConnectivity). The minimal viable configuration for carconenctivity with grafana is:
```json
{
    "carConnectivity": {
        "log_level": "error", // set the global log level, you can set individual log levels in the connectors and plugins
        "connectors": [
            {
                // Definition for your connector
                ...
            }
        ],
        "plugins": [
            {
                "type": "webui",
                "config": {
                    "username": "admin",
                    "password": "secret",
                }
            },{
                "type": "database",
                "config":{
                    "db_url": "postgresql://admin:secret@postgresdbbackend:5432/carconnectivity"
                }
            }
        ]
    }
}
```
Webui username and password must match the values in your .env file. db_url must match your database configuration in the .env file.
* Start the stack using your configuration.
```bash
docker compose --env-file ./myconfig.env up
```

* Open a browser to use the webinterface on http://IP-ADDRESS:4000
* Open a browser to use grafana on http://IP-ADDRESS:3000 with the user and password you selected