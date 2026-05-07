#!/bin/bash

# Configure php-fpm to listen on TCP instead of Unix socket
sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

mkdir -p /run/php

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mariadb -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} -e "SELECT 1;" > /dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready."

# Configure wp-config.php if it doesn't exist yet
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    cp /var/www/wordpress/wp-config-sample.php \
       /var/www/wordpress/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/wordpress/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/"          /var/www/wordpress/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/"      /var/www/wordpress/wp-config.php
    sed -i "s/localhost/mariadb/"                    /var/www/wordpress/wp-config.php
fi

# Install WordPress if not already installed
if ! wp core is-installed --path=/var/www/wordpress --allow-root; then
    wp core install \
        --path=/var/www/wordpress \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --path=/var/www/wordpress \
        --allow-root
fi

# Start php-fpm as PID 1
exec php-fpm8.2 --nodaemonize