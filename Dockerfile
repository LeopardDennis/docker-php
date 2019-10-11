FROM ubuntu:18.04
MAINTAINER forever88959@gmail.com

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm-color" \
    TZ="Asia/Shanghai" \
    LANGUAGE="en_US:en" \
    LANG="en_US.UTF-8" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"
    
# Install cURL
RUN apt-get -q update && apt-get install -yq curl bash software-properties-common vim git unzip supervisor && apt-get -y autoclean && apt-get -y clean

RUN add-apt-repository ppa:ondrej/php && apt-get -q update

# Install PHP
RUN apt-get install -yq php5.6-fpm php5.6-cli && \
    apt-get -y autoclean && apt-get -y clean && \
    mkdir -p /run/php && \
    mkdir -p /var/lib/workspace && \
    mkdir -p /var/log/php5 && \
    touch /var/log/php5/cgi.log && \
    touch /var/log/php5/cli.log && \
    chown -R www-data:www-data /var/log/php5 && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php/5.6/fpm/pool.d/www.conf && \
    sed -i 's/^error_log\s*=.*$/error_log = syslog/' /etc/php/5.6/fpm/php-fpm.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php5\/cgi.log/' /etc/php/5.6/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/var\/log\/php5\/cli.log/' /etc/php/5.6/cli/php.ini

RUN apt-get install -yq php5.6-intl php5.6-gd php5.6-mysql php-redis php5.6-sqlite php5.6-curl php5.6-zip php5.6-mbstring php5.6-ldap php-dev

RUN apt-get install -yq libyaml-dev && \
    pecl install yaml-2.0.4 && \
    echo "extension=yaml.so" > /etc/php/5.6/mods-available/yaml.ini && \
    phpenmod yaml

# Install Composer
RUN mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) && \
    mv composer.phar /usr/local/bin/composer && \
    echo 'export PATH="/usr/local/share/composer/vendor/bin:$PATH"' >> /etc/profile.d/composer.sh

ADD supervisor.php5-fpm.conf /etc/supervisor/conf.d/php5-fpm.conf

EXPOSE 9000

WORKDIR /var/lib/workspace

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
