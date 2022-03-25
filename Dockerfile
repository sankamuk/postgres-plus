FROM centos:centos7
MAINTAINER Sankar Mukherjee <sanmuk21@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install sudo epel-release; yum clean all
RUN yum -y install postgresql-server postgresql postgresql-contrib supervisor pwgen; yum clean all

# Add Setup Scripts
ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start_postgres.sh /start_postgres.sh

# Setup permissions
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers
RUN chmod +x /usr/bin/postgresql-setup
RUN chmod +x /start_postgres.sh
RUN usermod -G wheel postgres

# Initialize Database
RUN /usr/bin/postgresql-setup

# Add configuration
ADD ./postgresql.conf /var/lib/pgsql/data/postgresql.conf
RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf

# Allow remote access
RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/data/pg_hba.conf

# Take initial state snapshot
RUN cp -r /var/lib/pgsql /var/lib/pgsql_at_init

# Declaration
VOLUME ["/var/lib/pgsql"]
EXPOSE 5432

# Startup
CMD ["/bin/bash", "/start_postgres.sh"]
