# Legends Browser for Sandstorm

This is a package of [Legends Browser](https://github.com/robertjanetzko/LegendsBrowser),
an open-source Java-based legends viewer for [Dwarf Fortress](http://www.bay12games.com/dwarves/),
for [Sandstorm](https://sandstorm.io/). Sandstorm is a platform intended to be a one-click
installer for web applications. As Legends Browser is, essentially, a web application,
and I wanted an easy way to host information about some of my DF worlds on the internet,
Sandstorm seemed like the obvious choice of platform to use.

To that end, this repository contains a small Flask web application designed to run in
front of Legends Browser. Its sole purpose is to allow users to upload Dwarf Fortress
legends dumps to it, and then run Legends Browser. Reverse proxy configuration for
Apache httpd is also included to run both applications on the same host. The Flask
application is currently rather primitive, with a very basic HTML GUI, but it serves
its purpose.

The Sandstorm information is inside .sandstorm/, and contains the package metadata and
scripts to start everything up. Sandstorm apps run in containers; this particular one
runs in a Fedora container (unlike the Debian containers most Sandstorm apps run in),
as I am a Fedora packager and had recently packaged Legends Browser for Fedora.

# Authors

The flask app, Apache configuration, and Sandstorm package were written by and are
maintained by Ben Rosser (me). They are all under the MIT license.

Legends Browser is developed by Robert Janetzko, which is also under the MIT license.

If you have issues with this Sandstorm package of Legends Browser, file a bug here
first before opening an upstream issue.
