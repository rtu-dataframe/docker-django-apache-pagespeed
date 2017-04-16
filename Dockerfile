FROM ubuntu:latest

ARG DJANGO_APP_NAME=django_helloworld

# Set terminal to be noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    wget \
    htop \
    tree \
    nano \
    apache2 \
    python3 \
    python3-pip \
    python-mysqldb \
    libmysqlclient-dev \
    libapache2-mod-wsgi-py3

RUN pip3 install --upgrade pip    


RUN a2dismod mpm_event
RUN a2dismod mpm_worker
RUN a2enmod mpm_prefork
RUN a2enmod info
RUN a2enmod status
RUN a2enmod wsgi
RUN a2enmod deflate
RUN a2enmod expires
RUN a2enmod headers

# Configure Server-Info/Server-Status Apache Webpage (on 000-default.conf)
ADD ./files/000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2ensite 000-default.conf


#Installing and configuring mod_pagespeed
RUN wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
RUN dpkg -i mod-pagespeed-*.deb
RUN rm mod-pagespeed-*.deb
ADD ./files/pagespeed.conf /etc/apache2/mods-available/pagespeed.conf
RUN a2enmod pagespeed

# Configure Django project
RUN mkdir django_app
WORKDIR /django_app
ADD ./files/requirements.txt /django_app/${DJANGO_APP_NAME}/requirements.txt
RUN pip install -r ${DJANGO_APP_NAME}/requirements.txt
#RUN django-admin startproject ${DJANGO_APP_NAME}

#Adding wildcard to allowed hosts
#RUN sed -i -e "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\'*\'\]/" /django_app/${DJANGO_APP_NAME}/${DJANGO_APP_NAME}/settings.py

#Django Apache configuration
ADD ./files/django_helloworld.conf /etc/apache2/sites-available/django_helloworld.conf
#RUN mv /etc/apache2/sites-available/django_helloworld.conf /etc/apache2/sites-available/${DJANGO_APP_NAME}.conf
RUN a2ensite ${DJANGO_APP_NAME}

#Testing Apache configuration
RUN apachectl configtest
RUN service apache2 restart


ADD ./files/init.sh /init.sh
RUN chmod ug+x /init.sh


#Cleaning packages
RUN apt-get clean \
    apt-get autoremove

VOLUME ["/django_app"]


# Expose ports
# 80 = Apache
EXPOSE 80

# Run Apache
ENTRYPOINT ["/init.sh"]


