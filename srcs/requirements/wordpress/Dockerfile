FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress \
    && wget -q https://wordpress.org/latest.tar.gz -P /tmp \
    && tar -xzf /tmp/latest.tar.gz -C /var/www \
    && rm /tmp/latest.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress \
    && chmod -R 755 /var/www/wordpress

COPY tools/wordpress_script.sh /wordpress_script.sh
RUN chmod +x /wordpress_script.sh

EXPOSE 9000

CMD ["/wordpress_script.sh"]