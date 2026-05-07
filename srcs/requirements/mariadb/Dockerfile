FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server

COPY conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 3306

CMD ["/script.sh"]