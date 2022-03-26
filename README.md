# postgres-plus

![Docker](https://img.shields.io/badge/platform-docker-brightgreen.svg)
![Postgres](https://img.shields.io/badge/software-Postgres-brightgreen.svg)

This repository provides Docker image build setup for an `Single Centos` node `Postgres` instance with `Persistent Volume` support. 

- Build

```
docker build -t <yourname>/postgres-plus .
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


- Features:
  - Build on Centos 7
  - Postgres single instance
  - Automatic User and DB creation, also allowing full access for the User on the DB
  - Allow peristent volume, thus preserving database data over container restart
  - Allow remote login using user id and password


- Demo

-- ***Build***

```
[sankar@localhost postgres-plus-main]$ docker build -t sanmuk21/postgres-plus:1.9.2 .
Sending build context to Docker daemon   42.5kB
Step 1/20 : FROM centos:centos7
 ---> eeb6ee3f44bd
Step 2/20 : MAINTAINER Sankar Mukherjee <sanmuk21@gmail.com>
 ---> Using cache
 ---> f6d634866f33
Step 3/20 : RUN yum -y update; yum clean all

	...

Step 20/20 : CMD ["/bin/bash", "/start_postgres.sh"]
 ---> Using cache
 ---> 31fb8ec75c27
Successfully built 31fb8ec75c27
Successfully tagged sanmuk21/postgres-plus:1.9.2
```

-- ***Run (with volume)***

```
[sankar@localhost postgres-plus-main]$ mkdir /home/sankar/postgres-plus/postgres-plus-main/db_data
[sankar@localhost postgres-plus-main]$ docker run --network=dbtest -d -p 5432:5432 \
> -v /home/sankar/postgres-plus/postgres-plus-main/db_data:/var/lib/pgsql \
> -e 'POSTGRESQL_USER=airflow' \
> -e 'POSTGRESQL_PASSWORD=airflow' \
> -e 'POSTGRESQL_DATABASE=airflow' \
> --name server sanmuk21/postgres-plus:1.9.2
dda89db73438cb0524d97c960b55abafda7748b95ef8f62b8fbd8287f336e9f9
[sankar@localhost postgres-plus-main]$ docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                    NAMES
dda89db73438   sanmuk21/postgres-plus:1.9.2   "/bin/bash /start_po…"   5 seconds ago   Up 4 seconds   0.0.0.0:5432->5432/tcp   server


[sankar@localhost postgres-plus-main]$ docker exec -it server bash
[root@dda89db73438 /]# su - postgres
-bash-4.2$ psql
psql (9.2.24)
Type "help" for help.

postgres=# \c airflow
You are now connected to database "airflow" as user "postgres".
airflow=# create table t1 (id int);
CREATE TABLE
airflow=# insert into t1 values (1), (2), (3);
INSERT 0 3
airflow=# select * from t1;
 id 
----
  1
  2
  3
(3 rows)

airflow=# \q
-bash-4.2$
```

-- ***Destroy***

```
[sankar@localhost postgres-plus-main]$ docker stop server && docker rm server
server
server
[sankar@localhost postgres-plus-main]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[sankar@localhost postgres-plus-main]$ 
```

-- ***Rerun (with old volume)***

```
[sankar@localhost postgres-plus-main]$ docker run --network=dbtest -d -p 5432:5432 \
> -v /home/sankar/postgres-plus/postgres-plus-main/db_data:/var/lib/pgsql \
> -e 'POSTGRESQL_USER=airflow' \
> -e 'POSTGRESQL_PASSWORD=airflow' \
> -e 'POSTGRESQL_DATABASE=airflow' \
> --name server sanmuk21/postgres-plus:1.9.2
c121ac8134843b0947187f5b1e414b27e6e87a5e1b038b5c38d755d2c2488336
[sankar@localhost postgres-plus-main]$ docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED          STATUS         PORTS                    NAMES
c121ac813484   sanmuk21/postgres-plus:1.9.2   "/bin/bash /start_po…"   10 seconds ago   Up 9 seconds   0.0.0.0:5432->5432/tcp   server
[sankar@localhost postgres-plus-main]$ docker exec -it server bash
[root@c121ac813484 /]# su - postgres
-bash-4.2$ psql
psql (9.2.24)
Type "help" for help.

postgres=# \c airflow
You are now connected to database "airflow" as user "postgres".
airflow=# select * from t1 ;
 id 
----
  1
  2
  3
(3 rows)

airflow=# \c
You are now connected to database "airflow" as user "postgres".
airflow=#
```


> Note this implementation is largely based on the work of https://github.com/CentOS/CentOS-Dockerfiles/tree/master/postgres/centos7
