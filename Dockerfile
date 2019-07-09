FROM ubuntu:bionic-20190612
LABEL maintainer="sameer@damagehead.com"

ENV PHP_VERSION=7.2 \
    AKAUNTING_VERSION=1.3.17 \
    AKAUNTING_USER=www-data \
    AKAUNTING_INSTALL_DIR=/var/www/akaunting \
    AKAUNTING_DATA_DIR=/var/lib/akaunting \
    AKAUNTING_CACHE_DIR=/etc/docker-akaunting

ENV AKAUNTING_BUILD_DIR=${AKAUNTING_CACHE_DIR}/build \
    AKAUNTING_RUNTIME_DIR=${AKAUNTING_CACHE_DIR}/runtime

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      sudo wget unzip nginx mysql-client gettext-base \
      php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-gd php${PHP_VERSION}-curl php${PHP_VERSION}-zip \
      php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring \
 && sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -i 's/^;env\[PATH\]/env\[PATH\]/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${AKAUNTING_BUILD_DIR}/

RUN bash ${AKAUNTING_BUILD_DIR}/install.sh

COPY assets/runtime/ ${AKAUNTING_RUNTIME_DIR}/

COPY assets/tools/ /usr/bin/

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

WORKDIR ${AKAUNTING_INSTALL_DIR}

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["app:akaunting"]

EXPOSE 80/tcp 9000/tcp
