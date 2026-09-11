FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server

COPY conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
COPY tools/maria_script.sh /maria_script.sh

RUN chmod +x /maria_script.sh

EXPOSE 3306

CMD ["/maria_script.sh"]
