# Etherpad Lite image for docker

## Note for This Fork

Features:
 * Use `MYSQL_PORT_3306_TCP_ADDR` instead of hard-coded `mysql` for database name, suitable for use in DaoCloud
 * Install plugins automatically: set `ETHERPAD_PLUGINS` to a comma separated list of npm package names.
 * Modified auto-generated config file to be production-ready and removed deprecated value.
 * [Docker Hub link](https://hub.docker.com/r/jamesits/docker-etherpad-lite/)

----------

This is a docker image for [Etherpad Lite](http://etherpad.org/) collaborative
text editor. The Dockerfile for this image has been inspired by the
[official Wordpress](https://registry.hub.docker.com/_/wordpress/) Dockerfile and
[johbo's etherpad-lite](https://registry.hub.docker.com/u/johbo/etherpad-lite/)
image.

This image uses an mysql container for the backend for the pads. It is based
on debian jessie instead of the official node docker image, since the latest
stable version of etherpad-lite does not support npm 2.

## About Etherpad Lite

> *From the official website:*

Etherpad allows you to edit documents collaboratively in real-time, much like a live multi-player editor that runs in your browser. Write articles, press releases, to-do lists, etc. together with your friends, fellow students or colleagues, all working on the same document at the same time.

![alt text](http://i.imgur.com/zYrGkg3.gif "Etherpad in action on PrimaryPad")

All instances provide access to all data through a well-documented API and supports import/export to many major data exchange formats. And if the built-in feature set isn't enough for you, there's tons of plugins that allow you to customize your instance to suit your needs.

You don't need to set up a server and install Etherpad in order to use it. Just pick one of publicly available instances that friendly people from everywhere around the world have set up. Alternatively, you can set up your own instance by following our installation guide

## Quickstart

First you need a running mysql container, for example:

```bash
$ docker run -d -e MYSQL_ROOT_PASSWORD=password --name ep_mysql mysql
```

Finally you can start an instance of Etherpad Lite:

```bash
$ docker run -d --link=ep_mysql:mysql -p 9001:9001 jamesits/etherpad-lite
```

This will create an etherpad database to the mysql container, if it does not
already exist. You can now access Etherpad Lite from http://localhost:9001/

## Environment variables

This image supports the following environment variables:

* `ETHERPAD_TITLE`: Title of the Etherpad Lite instance. Defaults to "Etherpad".
* `ETHERPAD_PORT`: Port of the Etherpad Lite instance. Defaults to 9001.

* `ETHERPAD_ADMIN_PASSWORD`: If set, an admin account is enabled for Etherpad,
and the /admin/ interface is accessible via it.
* `ETHERPAD_ADMIN_USER`: If the admin password is set, this defaults to "admin".
Otherwise the user can set it to another username.

* `ETHERPAD_PLUGINS`: Comma-separated list for plugins to install by default
 (on each start). Remember to use full name in npm repo, e.g.
`ep_adminpads,ep_headings2`.
* `ETHERPAD_MAXAGE`: HTTP cache max age. Defaults to 3600.

* `ETHERPAD_DB_USER`: By default Etherpad Lite will attempt to connect as root
to the mysql container. This allows to change this.
* `ETHERPAD_DB_PASSWORD`: The password for the mysql user. If the root user is
used, then the password will default to the mysql container's
`MYSQL_ROOT_PASSWORD`.
* `ETHERPAD_DB_NAME`: The mysql database to use. Defaults to *etherpad*. If the
database is not available, it will be created when the container is launched.
* `MYSQL_PORT_3306_TCP_ADDR`: The database hostname or IP. Port will be 3306
by default.

The generated settings.json file will be available as a volume under
*/opt/etherpad-lite/var/*.
