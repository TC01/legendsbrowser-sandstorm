#!/bin/bash
set -euo pipefail
# This script is run every time an instance of our app - aka grain - starts up.
# This is the entry point for your application both when a grain is first launched
# and when a grain resumes after being previously shut down.
#
# This script is responsible for launching everything your app needs to run.  The
# thing it should do *last* is:
#
#   * Start a process in the foreground listening on port 8000 for HTTP requests.
#
# This is how you indicate to the platform that your application is up and
# ready to receive requests.  Often, this will be something like nginx serving
# static files and reverse proxying for some other dynamic backend service.
#
# Other things you probably want to do in this script include:
#
#   * Building folder structures in /var.  /var is the only non-tmpfs folder
#     mounted read-write in the sandbox, and when a grain is first launched, it
#     will start out empty.  It will persist between runs of the same grain, but
#     be unique per app instance.  That is, two instances of the same app have
#     separate instances of /var.
#   * Preparing a database and running migrations.  As your package changes
#     over time and you release updates, you will need to deal with migrating
#     data from previous schema versions to new ones, since users should not have
#     to think about such things.
#   * Launching other daemons your app needs (e.g. mysqld, redis-server, etc.)

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.

set -x

cd /opt/app

# Create some directory structure?
mkdir -p /var/log/httpd
mkdir -p /var/run/httpd
mkdir -p /var/www/html
mkdir -p /var/lib/legendsbrowser-flask
mkdir -p /var/tmp

# Remove old httpd pid file.
rm -f /var/run/httpd.pid

# Remove old run-legendsbrowser lock file.
rm -f /var/tmp/run-legendsbrowser-lock

# Point tmpdir at /var/tmp
export TMPDIR=/var/tmp

# Configure Java properly.
export JAVA_HOME=/usr/lib/jvm/java-1.8.0/
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib:$JAVA_HOME/jre/lib/amd64:$JAVA_HOME/jre/lib/amd64/jli:$JAVA_HOME/jre/lib/server"

# Launch Legends Browser, wait for it to connect.
/opt/app/legendsbrowser-flask.py -d /var/lib/legendsbrowser-flask/ &
while ! nc -vn -w 1 127.0.0.1 5000 ; do
	echo "Waiting for Flask app to start..."
done

# Launch httpd.
/usr/sbin/httpd -f /opt/app/legendsbrowser-apache.conf -DFOREGROUND -DNO_DETACH

