# Docker Roundcube Container (marvambass/roundcube)
_maintained by MarvAmBass_

[FAQ - All you need to know about the marvambass Containers](https://marvin.im/docker-faq-all-you-need-to-know-about-the-marvambass-containers/)

## What is it

This Dockerfile (available as ___marvambass/roundcube___) gives you a completly secure roundcube.

It's based on the [marvambass/nginx-ssl-php](https://registry.hub.docker.com/u/marvambass/nginx-ssl-php/) Image

View in Docker Registry [marvambass/roundcube](https://registry.hub.docker.com/u/marvambass/roundcube/)

View in GitHub [MarvAmBass/docker-roundcube](https://github.com/MarvAmBass/docker-roundcube)

## Environment variables and defaults

### For Headless installation required

Roundcube Settings

* __ROUNDCUBE\_PHP\_DATE_TIMEZONE__
 * default _Europe/Berlin_ - use whatever you need

Roundcube Install Settings

* __ROUNDCUBE\_DO\_NOT_INITIALIZE__
 * not set by default - it set with any value, initialization process is skipped

Roundcube Database Settings

* __ROUNDCUBE\_MYSQL\_USER__
 * no default - if null it will use sqlite
* __ROUNDCUBE\_MYSQL\_PASSWORD__
 * no default - if null it will use sqlite
* __ROUNDCUBE\_MYSQL\_HOST__
 * default: _mysql_
* __ROUNDCUBE\_MYSQL\_PORT__
 * default: _3306_ - if you use a different mysql port change it
* __ROUNDCUBE\_MYSQL\_DBNAME__
 * default: _roundcube_

Roundcube Site Settings

* __ROUNDCUBE\_RELATIVE\_URL\_ROOT__
 * default: _/_ - you can chance that to whatever you want/need
* __ROUNDCUBE\_HSTS\_HEADERS\_ENABLE__
 * default: not set - if set to any value the HTTP Strict Transport Security will be activated on SSL Channel
* __ROUNDCUBE\_HSTS\_HEADERS\_ENABLE\_NO\_SUBDOMAINS__
 * default: not set - if set together with __ROUNDCUBE\_HSTS\_HEADERS\_ENABLE__ and set to any value the HTTP Strict Transport Security will be deactivated on subdomains

### Inherited Variables

* __DH\_SIZE__
 * default: 1024 fast but a bit insecure. if you need more security just use a higher value
 * inherited from [MarvAmBass/docker-nginx-ssl-secure](https://github.com/MarvAmBass/docker-nginx-ssl-secure)

## Using the marvambass/roundcube Container

First you need a running MySQL Container (you could use: [marvambass/mysql](https://registry.hub.docker.com/u/marvambass/mysql/)).

You need to _--link_ your mysql container to marvambass/roundcube with the name __mysql__, and also link a valid imap smtp mail server with the name __mail__ to it.

    docker run -d -p 443:443 --link mysql:mysql --link mail:mail -e 'ROUNDCUBE_MYSQL_USER=username' -e 'ROUNDCUBE_MYSQL_PASSWORD=pa55worD' --name roundcube marvambass/roundcube
