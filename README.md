# Grafana provisioned for CarConnectivity Software
This image provisions Grafana with the following:
- datasource to connect to SQLite database with data from the car
- dashboards visualizing data from the car

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