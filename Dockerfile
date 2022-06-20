FROM php:8.1-fpm-alpine

WORKDIR  /var/www

RUN apk update && apk add \
    build-base \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    zip \
    vim \
    unzip \
    git \
    jpegoptim optipng pngquant gifsicle \
    php-curl \
    curl \
    php-cli 


RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd  --with-freetype=/usr/include/ --with-jpeg=/usr/include/ 
RUN docker-php-ext-install gd

RUN cd ~
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php


RUN apk add autoconf && pecl install -o -f redis \
&& rm -rf /tmp/pear \
&& docker-php-ext-enable redis && apk del autoconf

COPY ./config/php/local.ini /usr/local/etc/php/conf.d/local.ini

RUN addgroup -g 777 -S www && \
    adduser -u 777 -S www -G www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

 RUN chown -R www:www /var/www/storage
 RUN chmod -R 777 /var/www/storage
 RUN chmod -R 777 storage bootstrap/cache
 RUN chmod -R 777 ./

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]