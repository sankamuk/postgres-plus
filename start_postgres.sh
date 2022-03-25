#!/bin/bash
# start_postgres - Startup script
# set -x

DB_NAME=${POSTGRES_DB:-airflow}
DB_USER=${POSTGRES_USER:-airflow}
DB_PASS=${POSTGRES_PASSWORD:-airflow}
PG_CONFDIR="/var/lib/pgsql/data"
PG_CONFDIR_BACKUP="/var/lib/pgsql_at_init/data"

# Method to (1) Enable persistent Volume support, (2) Creation of Database and Users
_prep_db() {

  if [ ! -d ${PG_CONFDIR} ]
  then
      echo "Detected new volume attached with no history, thus restore DB initiation image"
      cp -r ${PG_CONFDIR_BACKUP} ${PG_CONFDIR} && chown -R postgres.postgres ${PG_CONFDIR}
      if [ $? -ne 0 ]
      then
          echo "Failed - Could not restore constant backup of initiation. Check volume mounted is usable"
          exit 1
      fi
  fi

  echo "Creation of postgres user profile and command history"
  cp /var/lib/pgsql_at_init/.bash_profile /var/lib/pgsql/ && \
        chown postgres.postgres /var/lib/pgsql/.bash_profile && \
    touch /var/lib/pgsql/.psql_history && \
    chown postgres.postgres var/lib/pgsql/.psql_history	


  echo "Validating whether DB already present from history"
  echo "SELECT datname FROM pg_database;" | sudo -u postgres -H postgres --single \
    -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR} | grep "${DB_NAME}"
  if [ $? -ne 0 ]
  then
      echo "DB not present thus DB and User will be created"
      echo "CREATE ROLE ${DB_USER} with CREATEROLE login superuser PASSWORD '${DB_PASS}';" | sudo -u postgres \
      -H postgres --single -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
      echo "CREATE DATABASE ${DB_NAME};" | sudo -u postgres -H postgres --single \
      -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
      echo "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} to ${DB_USER};" | sudo -u postgres \
      -H postgres --single -c config_file=${PG_CONFDIR}/postgresql.conf -D ${PG_CONFDIR}
  fi

}


# Method to start Posrgres instance
_run_supervisor() {
    supervisord -n
}

# Call all functions
_prep_db
_run_supervisor
