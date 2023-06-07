# Ishigaki

[![Build Status](https://travis-ci.org/Digital-Identity-Labs/ishigaki.svg?branch=master)](https://travis-ci.org/Digital-Identity-Labs/ishigaki)
[![Docker Stars](https://img.shields.io/docker/stars/digitalidentity/ishigaki.svg)](https://hub.docker.com/r/digitalidentity/ishigaki/)
[![Image Details](https://images.microbadger.com/badges/image/digitalidentity/ishigaki.svg)](https://microbadger.com/images/digitalidentity/ishigaki "Get your own image badge on microbadger.com")

## What is this?

[Shibboleth Identity Provider](https://www.shibboleth.net/products/identity-provider/) is a mature, SAML-based single
sign on (SSO) web application widely deployed in academic organisations. It's used by millions of staff and students
around the world.

Ishigaki is a minimalist, Debian-based, Shibboleth IdP Docker image. It is maintained
by [Digital Identity Ltd.](http://digitalidentity.ltd.uk/)
Ishigaki is intended to be a solid foundation for other images but can also be used directly by mounting volumes for
configuration directories.

The latest Ishigaki is based around Shibboleth IdP v4.3.1 and has support for installing plugins and managing modules.

This image is *not* a ready-to-use, stand-alone IdP service - it's meant to be configured and then used in conjunction
with other services to handle TLS, databases, LDAP, and so on. It's especially well suited to use with Docker Compose or
Swarm, Nomad or Kubernetes. Ishigaki aims to be a good Docker image with careful use of layers, correct signal handling,
a non-root process, logging to STDOUT by default and a healthcheck.

## Why use this?

* **Modern**: uses the latest Shibboleth IdP, Jetty and Debian OS, and build for both AMD64 and ARM64 architectures
* **Smaller**: based on Minideb and built carefully, Ishigaki is only around 400MB and the download is under 280MB
* **Secure**: updated regularly, nothing runs as root, and directory permissions are managed
* **Tested**: Ishigaki is built and tested automatically
* **Maintained**: we use this image ourselves
* **Compliant**: follows Docker best practices, responds to signals correctly, logs to STDOUT
* **Convenient**: We include build scripts for making your own images

## Any reasons not to use this?

* It is *not* ready-to-use, and there is no UI or simplified configuration: you need to understand how to configure a
  Shibboleth IdP.
* It's got no warranty or support (but see Ishigaki Academic Edition details below)
* It does not use the official Oracle JDK - it uses Amazon's own JDK
* It requires other supporting services to provide TLS and user information (or special configuration)
* Docker should not be used in production unless you have a reliable process for regularly updating images and replacing
  containers

## Configuring and running Ishigaki

## Releases

Images are available from Dockerhub and Github:

* https://hub.docker.com/repository/docker/digitalidentity/ishigaki
* https://github.com/orgs/Digital-Identity-Labs/packages/container/package/ishigaki

Three versions are available:

* Default: This image contains the default IdP install for use with password authentication and LDAP.
* Base: This has no plugins or modules enabled, and the .war has not been built. Base is intended to be used as a base
  image or as a Jetty container using mounted volumes to provide the shibboleth-idp directory.
* Plus: Additional plugins and modules enabled by default, including Javascript, TOTP and OIDC.

### Getting the image

* `docker pull digitalidentity/ishigaki:latest` to get the latest default version from DockerHub
* `docker pull ghcr.io/digital-identity-labs/ishigaki:latest-plus"` to get the latest plus version from Github
* `docker pull ghcr.io/digital-identity-labs/ishigaki:3.0.0-base"` to get a specific base version from Github

### Configuring the IdP

Run the unconfigured default IDP in the foreground, with a http port available:

`docker run -it -p 8080:8080 digitalidentity/ishigaki`

Copy the current configuration from the running container:

```bash
containerid=$(docker ps | grep ishigaki | awk '{print $1}')

docker cp $containerid:/opt ./optfs

docker stop $containerid
```

Most of the useful configuration for Ishigaki is in various /opt directories:

* `admin` - this contains some internal tools.
* `jetty` - the global Jetty configuration.
* `jetty-shib` - extra Jetty configuration files for running Shibboleth
* `misc` - a few other files
* `shibboleth-idp` - the Shibboleth IDP configuration

Adjust these files to suit your use-case - see the
[Shibboleth IdP documentation](https://wiki.shibboleth.net/confluence/display/IDP4/Home) for lots more information.

As you're probably copying these files over the top of existing files, you don't need to keep copies of files you aren't
changing. You can usually not bother with the admin, jetty and misc directories. You will probably only need to change
the jetty-shib directory if you are adding TLS or backchannel ports directly to the IdP, rather than using a proxy.

### Running Ishigaki with your configuration

Then you can either build an image that contains your configuration, like this:

```dockerfile
FROM ghcr.io/digital-identity-labs/ishigaki:latest-base
# (Don't use latest in production)

LABEL description="An example IdP image based on Ishigaki" \
      version="0.0.1" \
      maintainer="example@example.com"

ARG PLUGINS="https://shibboleth.net/downloads/identity-provider/plugins/oidc-common/2.2.0/oidc-common-dist-2.2.0.tar.gz \
             https://shibboleth.net/downloads/identity-provider/plugins/oidc-op/3.4.0/idp-plugin-oidc-op-distribution-3.4.0.tar.gz"
ARG MODULES="idp.oidc.OP"


## The prepare_apps.sh script can use these - but they're not needed otherwise
ENV IDP_HOSTNAME=idp.example.com \
    IDP_SCOPE=example.com \
    IDP_ID=https://idp.example.com/idp/shibboleth

RUN for plugin in $PLUGINS; do $IDP_HOME/bin/plugin.sh -i $plugin ; done && \
    $IDP_HOME/bin/module.sh -i $MODULES ; $IDP_HOME/bin/module.sh -e $MODULES

## Copy your configuration files over into the image
COPY optfs /opt

```

or run the Ishigaki image with mounted directories

`docker run -v /home/bjensen/myshib/optfs/shibboleth-idp:/opt/shibboleth-idp digitalidentity/ishigaki`

### Using with Docker Compose

Running a relatively bare Ishigaki container on its own is only useful for some basic dev or testing work. It's far more
useful when used with other Docker containers.

For example, a `docker-compose.yml` file like this can provide a basic IdP service, with TLS and LDAP:

```docker-compose
version: '3'
services:
  frontend:
    image: traefik:latest
    command: --web --docker --docker.domain=docker.localhost --logLevel=DEBUG
    ports:
      - "443:443"
      - "8080:8080"
      - "8433:8443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./frontend/traefik.toml:/traefik.toml
      - ./frontend/certs:/certs

  ldap:
    image: digitalidentity/eduldap:latest
    labels:
      - "traefik.enable=false"

  idp:
    image: digitalidentity/ishigaki:latest
    volumes:
     - ./idp/shibboleth-idp:/opt/shibboleth-idp
    labels:
      - "traefik.backend=idp"
      - "traefik.frontend.passHostHeader=true"
      - "traefik.frontend.rule=Host:idp.localhost.demo.university"
      - "traefik.frontend.entryPoints=https"
      - "traefik.port=8080"
      - "traefik.protocol=http"

```

(This is not going to work on its own - you'll need to use your own data, Traefik configuration, LDAP data, etc)

### When building an image based on Ishigaki

Possibly useful things to know:

* The Ishigaki repository uses the Inspec tests from
  the [ishigaki-spec](https://github.com/Digital-Identity-Labs/ishigaki-spec) profile on Github. You can use this to
  test your own Docker image by including it as a dependency in your inSpec profile. Look at the code in the Ishigaki
  repo to see how it's done. set of tests

### When using Ishigaki's Dockerfile to build your own images

The defaults for these settings can be changed by using `--build-arg THE_ARG="new setting"` with `docker build`

  *  JETTY_URL Set to URL of Jetty if you want to install a different version
  *  JETTY_CHECKSUM SHA1 checksum of the Jetty archive
  *  IDP_URL URL for downloading the IdP archive (as a tar.gz)
  *  IDP_CHECKSUM SHA256 checksum for the Shibboleth IdP archive
  *  EDWIN_STARR Set to "1" if building a .war is good for absolutely nothing (in a base image)
  *  DELAY_WAR Set to "1" to delay building a .war until the plugin management stage
  *  IDP_HOSTNAME DNS hostname of your IdP
  *  IDP_ID Entity URI of your IdP
  *  IDP_SCOPE Scope domain of your IdP
  *  IDP_KEYSIZE Keysize for your IdP
  *  SPASS Default sealer password - it's best to use a placeholder while building
  *  KPASS Default keystore password - it's best to use a placeholder while building
  *  CREDS_MODE Posix file permissions for credential files
  *  CREDS_GROUP Group that should be able to access credential files
  *  IDP_PROPERTIES Java properties (as a string) that will be merged with default IdP properties
  *  LDAP_PROPERTIES Java properties (as a string) that will be merged with default LDAP properties
  *  MODULES A comma-seperated list of module IDs to enable from the main Shibboleth package
  *  PLUGINS A whitespace-seperated list of plugin file paths or URLs to be installed
  *  PLUGIN_IDS A whitespace-seperated list of official plugin IDs to be installed
  *  PLUGIN_MODULES A comma-seperated list of module IDs to install after plugins
  *  WRITE_MD Set to "0" to have stricter write permissions in the metadata directory

### Running without a reverse proxy

Unlike most IdP images Ishigaki assumes it is behind a reverse proxy such as Apache HTTPD or Traefik. The default
configuration accepts and trusts some HTTP headers that it assumes carry information from the proxy.

If you add TLS, backchannel ports, etc and run Ishigaki directly, without a proxy, please remove the configuration options for these headers, or they may be a security risk for your service.

## Other Information

### What's Ishigaki Academic Edition?

Ishigaki Academic Edition is a commercial, supported version of Ishigaki produced and supported
by [Mimoto Ltd](http://mimoto.co.uk). It can be used in exactly the same way, but has a few differences:

* Includes remote or on-site support from Mimoto
* Uses the official Oracle JDK (optional)
* Releases are manually checked, and given additional, more intensive tests
* Releases are signed, and available from a private repository

If you'd like more information about Ishigaki Academic Edition, please [contact Mimoto](http://mimoto.co.uk/contact/)

### Related Projects from Digital Identity

* eduLDAP - a quick and easy OpenLDAP image for HE use

### What does "ishigaki" mean?

Ishigaki are the impressive dry
stone [foundation walls of Japanese castles](http://jcastle.info/view/Stone_walls).
(Ishigaki is also the name of a beautiful [island and city in Okinawa](https://en.wikipedia.org/wiki/Ishigaki_Island))

## Alternatives

* [TIER's Shib IdP](https://github.internet2.edu/docker/shib-idp/) - Tomcat-based and actively maintained, but no ARM version.

### Thanks

* Ian Young's script to test Java crypto features has been included with his kind permission
* We're just packaging huge amounts of work by [The Shibboleth Consortium](https://www.shibboleth.net/consortium/) and
  the wider Shibboleth community. If your organisation depends on Shibboleth please consider supporting them with a
  donation.

### Contributing

You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/ishigaki/issues), or submit
a [pull request](https://github.com/Digital-Identity-Labs/ishigaki/pulls) with your contribution.

The Ishigaki repo contains tests that you can use in your own projects. We're extra grateful for any contributions that
include tests.

If you have a support contract with Mimoto, please [contact Mimoto](http://mimoto.co.uk/contact/) for assistance, rather
than use Github.

### License

Copyright (c) 2017,2023 Digital Identity Ltd, UK

Licensed under the MIT License
