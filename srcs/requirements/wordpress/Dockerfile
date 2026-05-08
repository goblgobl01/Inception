FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	mariadb-client \
	curl

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY tools/wordpress_script.sh /wordpress_script.sh
RUN chmod +x /wordpress_script.sh

EXPOSE 9000

CMD ["/wordpress_script.sh"]
