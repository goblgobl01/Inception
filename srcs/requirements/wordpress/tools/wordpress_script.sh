#!/bin/bash

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' \
	/etc/php/8.2/fpm/pool.d/www.conf

echo "waiting for mariadb..."
while ! mysqladmin ping -hmariadb -u$MYSQL_USER -p$MYSQL_PASSWORD --silent;
do
	sleep 1
done
if [ ! -f /var/www/wordpress/index.php ]
then
	wp core download --path=/var/www/wordpress --allow-root
	wp config create --allow-root --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=mariadb
	wp core install --url=https://${DOMAIN_NAME} \
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

exec php-fpm8.2 -F