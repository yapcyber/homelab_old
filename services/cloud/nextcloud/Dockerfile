# Nextcloud + module PHP smbclient (pour l'External Storage SMB/CIFS).
# On garde les deps de build (image un peu plus grosse mais build fiable).
FROM nextcloud:34.0.2-apache

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends $PHPIZE_DEPS libsmbclient-dev smbclient; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; \
    rm -rf /var/lib/apt/lists/*; \
    php -m | grep -q smbclient
