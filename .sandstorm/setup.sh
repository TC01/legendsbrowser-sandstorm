#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail
# This is the ideal place to do things like:
#
#    export DEBIAN_FRONTEND=noninteractive
#    apt-get update
#    apt-get install -y nginx nodejs nodejs-legacy python2.7 mysql-server
#
# If the packages you're installing here need some configuration adjustments,
# this is also a good place to do that:
#
#    sed --in-place='' \
#            --expression 's/^user www-data/#user www-data/' \
#            --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
#            --expression 's/^\s*error_log.*/error_log stderr;/' \
#            --expression 's/^\s*access_log.*/access_log off;/' \
#            /etc/nginx/nginx.conf

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.


# This is Fedora. Install our dwarffortress repository.
# Actually just install legendsbrowser from repos
#dnf install -y wget
#wget -P /etc/yum.repos.d/ https://www.acm.jhu.edu/~bjr/fedora/dwarffortress/dwarffortress.repo
#rpm --import https://www.acm.jhu.edu/~bjr/fedora/dwarffortress/df_gpg_key
dnf install -y --enablerepo=updates-testing legendsbrowser

# The version of flask in F24 is just a bit too old
dnf install -y python-pip
pip install flask
#dnf install -y python-flask

# We want a python lock file implementation
# This doesn't seem to be built into the stdlib!
dnf install -y python-fasteners python-monotonic

# We want python2-libarchive-c too~
dnf install -y python2-libarchive-c

# Install httpd
dnf install -y httpd
dnf install -y mod_proxy_html

# Install Java.
dnf install -y java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless

# Install some useful utilities
dnf install -y nmap-ncat
dnf install -y gnupg

# Tragically, we need to install maven in order to pull reflections-0.9.9.
# For exciting reasons, it seems we need reflections 0.9.9 to fix
# this bug: https://github.com/ronmamo/reflections/issues/81
dnf install -y maven
mvn dependency:get -Dartifact=org.reflections:reflections:0.9.9
cp -v ~/.m2/repository/org/reflections/reflections/0.9.9/reflections-0.9.9.jar /usr/share/java/reflections.jar

# Also deploy the configuration file for httpd here
cp -v /opt/app/legendsbrowser-apache.conf /etc/httpd/conf.d/

# Modify legendsbrowser to run with max 1 GB of RAM.
# Also modify it to set user.home property
sed 's/BASE_FLAGS=""/BASE_FLAGS="-Xmx1024M -Duser.home=\/var"/' -i /usr/bin/legendsbrowser

exit 0
