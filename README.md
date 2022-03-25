# postgres-plus

![Docker](https://img.shields.io/badge/platform-docker-brightgreen.svg)
![Postgres](https://img.shields.io/badge/software-Postgres-brightgreen.svg)

This repository provides Docker image build setup for an 'Single Centos' node 'Postgres' instance with 'Persistent Volume' support. 

- Build

```
docker build -t <>/postgres-plus .
```

- Run

```
docker run --name postgresql -d \
-v <your local directory>:/var/lib/pgsql
-e 'POSTGRESQL_USER=username' \
-e 'POSTGRESQL_PASSWORD=ridiculously-complex_password1' \
-e 'POSTGRESQL_DATABASE=my_database' \
<yourname>/postgresql
```

> Note this implementation is largely based on the work of https://github.com/CentOS/CentOS-Dockerfiles/tree/master/postgres/centos7
