# Nextcloud + module PHP smbclient (pour l'External Storage SMB/CIFS).
# Image officielle + compilation de l'extension via pecl (pattern officiel :
# on installe les deps de build, on compile, puis on purge en gardant le
# runtime libsmbclient / smbclient).
FROM nextcloud:34.0.2-apache

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends $PHPIZE_DEPS libsmbclient-dev smbclient; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    apt-mark manual smbclient > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    php -m | grep -q smbclient
