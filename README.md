# Qogita-Airbyte

Repo to manage all the Sources, Destinations and Connections in our Airbyte Instance.

### Requirements:
- GNU Make
- SSH key to interact with the EC2 instance

## Infrastructure:

Our Airbyte Instance is hosted in an EC2 instance in the AWS Data Science Prod Accound called `AirbyteInstanceProd`. 
The EC2 instance configuration details can be found in the [Infrastructure repo](https://github.com/qogita/infrastructure/blob/main/stacks/data_platform/airbyte_stack.py).

## How are the Airbyte components running:

The Airbyte Components run in Docker containers defined in the `docker-compose.yaml` + `.env` files located in the root of this repo.

## How to visit the Airbyte UI?

From the root of the repo run `make forward_ec2_port`. After that go to your browser http://localhost:8000/

## How do we keep track of our deploy resources in Airbyte?

We use [Octavia](https://airbyte.com/tutorials/version-control-airbyte-configurations#octavia-cli-use-cases) for that and we store them in the `octavia-configs` folder, found in the root of this repo.

### How to install Octavia?

From the root of the repo run:
```
make install_octavia; 
```
The idea is that we keep the repo updated with any manual change that may happen in the Airbyte UI, so everytime you create, delete or update a  Sources, Destinations or Connections, please, go to the `octavia-configs` folder and run:
```
octavia import all;
```
This will updated the configuration folders under `octavia-configs` with the infromation from our Airbyte Instance.


### Disaster Recovery:

If anything goes wrong and we need to be able to start up the service quickly. So, here is what to do under different circumstances.

- EC2 instance `AirbyteInstanceProd` must be always up and running. If it is not running, possible solutions:
1. Check that nobody remove it from the infrastructure repo.
2. Go to the AWS EC2 Console. Select the instance and try to start it manually.

- Check the docker containers running in the EC2 instance:
1. From the root of the repo run `make check_running_containers`. If you do not get an output similar to the following one, that means the docker containers are not running.
```
CONTAINER ID   IMAGE                                      COMMAND                  CREATED              STATUS              PORTS                                                                                                              NAMES
284387c87e68   airbyte/source-postgres:1.0.36             "/airbyte/base.sh re…"   About a minute ago   Up About a minute                                                                                                                      source-postgres-read-45-0-rtyqr
faa5a075e93f   airbyte/destination-snowflake:0.4.41       "/airbyte/base.sh wr…"   About a minute ago   Up About a minute                                                                                                                      destination-snowflake-write-45-0-smlbo
07a2e8364470   airbyte/proxy:0.40.28                      "./run.sh ./run.sh"      41 hours ago         Up 41 hours         0.0.0.0:8000-8001->8000-8001/tcp, :::8000-8001->8000-8001/tcp, 80/tcp, 0.0.0.0:8003->8003/tcp, :::8003->8003/tcp   airbyte-proxy
caae31336091   airbyte/worker:0.40.28                     "/bin/bash -c ${APPL…"   41 hours ago         Up 41 hours         0.0.0.0:49185->9000/tcp, :::49185->9000/tcp                                                                        airbyte-worker
b9587c97a571   airbyte/server:0.40.28                     "/bin/bash -c ${APPL…"   41 hours ago         Up 41 hours         8000/tcp, 0.0.0.0:49186->8001/tcp, :::49186->8001/tcp                                                              airbyte-server
9311c1884124   airbyte/cron:0.40.28                       "/bin/bash -c ${APPL…"   41 hours ago         Up 41 hours                                                                                                                            airbyte-cron
464481286fad   airbyte/connector-builder-server:0.40.28   "uvicorn connector_b…"   41 hours ago         Up 41 hours         0.0.0.0:49183->80/tcp, :::49183->80/tcp                                                                            airbyte-connector-builder-server
26a242559432   airbyte/webapp:0.40.28                     "/docker-entrypoint.…"   41 hours ago         Up 41 hours         0.0.0.0:49184->80/tcp, :::49184->80/tcp                                                                            airbyte-webapp
c555553553ab   airbyte/temporal:0.40.28                   "./update-and-start-…"   41 hours ago         Up 41 hours         6933-6935/tcp, 6939/tcp, 7233-7235/tcp, 7239/tcp                                                                   airbyte-temporal
23ecf5939bbd   airbyte/db:0.40.28                         "docker-entrypoint.s…"   41 hours ago         Up 41 hours         5432/tcp 
```

To start the service run `make disaster_recovery` from the root of the repo. Give it a minute and run `make check_running_containers` to check the containers running in the EC2 instance.

Once you see them running go into the `octavia-configs` folder and run `octavia apply`. That will copy all the configurations from the repo to the Airbyte instance. 