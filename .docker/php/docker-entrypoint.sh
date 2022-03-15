#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

PHP_EXT_DIR=/usr/local/etc/php/conf.d

# Enable PHP extensions
PHP_EXT_COM_ON=docker-php-ext-enable

[ -d ${PHP_EXT_DIR} ] && rm -f ${PHP_EXT_DIR}/docker-php-ext-*.ini

if [ -x "$(command -v ${PHP_EXT_COM_ON})" ] && [ ! -z "${PHP_EXTENSIONS}" ]; then
  ${PHP_EXT_COM_ON} ${PHP_EXTENSIONS}
fi

# Set host.docker.internal if not available
HOST_NAME="host.docker.internal"
HOST_IP=$(php -r "putenv('RES_OPTIONS=retrans:1 retry:1 timeout:1 attempts:1'); echo gethostbyname('$HOST_NAME');")
if [[ "$HOST_IP" == "$HOST_NAME" ]]; then
  HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
  printf "\n%s %s\n" "$HOST_IP" "$HOST_NAME" >> /etc/hosts
fi

# Handle composer credentials && run composer install
composer config --global http-basic.repo.magento.com $PUBLIC_KEY $PRIVATE_KEY

mkdir /app/vendor

composer install --no-progress --no-interaction

bin/magento setup:install \
  --db-host=db \
  --db-name=magento2 \
  --db-user=magento2 \
  --db-password=magento2 \
  --admin-firstname=admin \
  --admin-lastname=admin \
  --admin-email=gino@technative.nl \
  --admin-user=admin \
  --admin-password=admin123 \
  --use-rewrites=1 \
  --elasticsearch-host=elasticsearch \
  --elasticsearch-port=9200 \
  --session-save=files \
  --use-secure=0 \
  --use-secure-admin=0 \
  --backend-frontname=xpanel \
  --base-url=http://localhost/ \
  --base-url-secure=https://localhost/

bin/magento setup:static-content:deploy -f
bin/magento cache:flush

exec "$@"