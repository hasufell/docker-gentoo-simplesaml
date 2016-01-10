FROM        hasufell/gentoo-nginx:latest
MAINTAINER  Julian Ospald <hasufell@gentoo.org>


##### PACKAGE INSTALLATION #####

# copy paludis config
COPY ./config/paludis /etc/paludis

# clone our overlays
RUN git clone --depth=1 https://github.com/MOSAIKSoftware/mosaik-overlay.git \
	/var/db/paludis/repositories/mosaik-overlay && chgrp paludisbuild /dev/tty \
	&& cave sync mosaik-overlay
RUN eix-update

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x

# install tools set
RUN chgrp paludisbuild /dev/tty && cave resolve -c tools -x

# install simplesamlphp set
RUN chgrp paludisbuild /dev/tty && cave resolve -c simplesamlphp -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

################################

ENV SIMPLESAML_ROOT /var/www/localhost/htdocs/simplesamlphp

## nginx
RUN rm -rf /etc/nginx
COPY config/nginx /etc/nginx

## PHP
COPY config/php5/ext-active /etc/php/fpm-php5.5/ext-active
COPY config/php5/fpm.d /etc/php/fpm-php5.5/fpm.d

# add php to supervisord
RUN echo -e "\n\n[program:php5-fpm]\
\ncommand=/usr/bin/php-fpm -F -c /etc/php/fpm-php5.5/ -y /etc/php/fpm-php5.5/php-fpm.conf\
\nautorestart=false" >> /etc/supervisord.conf

# allow easy config file additions to php-fpm.conf
RUN echo "include=/etc/php/fpm-php5.5/fpm.d/*.conf" \
	>> /etc/php/fpm-php5.5/php-fpm.conf

EXPOSE 80 443


COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh && exec /usr/bin/supervisord -n -c /etc/supervisord.conf
