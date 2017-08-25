# Ishigaki

[![Build Status](https://travis-ci.org/Digital-Identity-Labs/ishigaki.svg?branch=master)](https://travis-ci.org/Digital-Identity-Labs/ishigaki)

## What is this?

Shibboleth Identity Provider is a mature, SAML-based single sign on (SSO) web application widely deployed in academic organisations. It's used by millions of staff and students around the world.

Ishigaki is a minimalist, Debian-based, Shibboleth IdP Docker image. It is maintained by Digital Identity Ltd. Ishigaki is intended to be a simple, solid foundation for other images but can also be used directly by mounting volumes for configuration directories.

This image is *not* a stand-alone production-ready IdP - it's meant to be used in conjunction with other services to handle TLS, databases, LDAP, and so on. It's especially well suited to use with Docker Compose, Rancher or Kubernetes. 

## Why use this?

* Modern: uses the latest Shibboleth IdP, Jetty and Debian OS.
* Small: Based on Minideb and built carefully, Ishigaki is only around 350MB and the download is under 180MB
* Secure: Updated daily, nothing runs as root, and directory permissions are managed
* Tested: Ishigaki is built and tested automatically
* Actively maintained: We use this image ourselves


## Any reasons not to use this?

* It is *not* ready-to-use, and there is no UI or simplified configuration: you need to understand how to configure a Shibboleth IdP
* It's got no warranty or support (but see Ishigaki Academic Edition details below)
* It does not use the official Oracle JDK - it uses a high quality JDK from Zulu, but Shibboleth community support may depend on using Oracle's software (again, see below for other options)
* It requires other supporting services to provide TLS and user information
* Docker should not be used in production unless you have a reliable process for regularly updating images and replacing containers
* It's relatively new - we expect to find more bugs 

## Configuring and running Ishigaki

### Getting the image

`docker #TODO `

### Configuring the IdP

Copy the current configuration from a running container:

`docker #TODO`

Or just grab the default IdP files from 

docker #TODO`

All the useful configuration for Ishigaki is in various /opt directories:

#TODO

Adjust these files to suit your use case - see the [Shibboleth IdP documentation](https://wiki.shibboleth.net/confluence/display/IDP30/Home) for lots more information.

As you're probably copying these files over the top of existing files, you don't need to keep copies of files you aren't changing.

### Running Ishigaki with your configuration

Then you can either build a child image that contains your configuration, like this

`docker #TODO`

Or run the Ishigaki image with mounted directories

`docker #TODO`

### Using with Docker Compose

Running a relatively bare Ishigaki on its own is only useful for some basic dev or testing work. It's far more useful when used with other Docker containers.

For example, a `docker-compose.yml` file like this can provide a basic IdP service:

`Docker-compose file`

## Other Information

### What's Ishigaki Academic Edition?

Ishigaki Academic Edition is a commercial, supported version of Ishigaki produced and supported by Mimoto Ltd. It can be used in exactly the same way, but has a few differences:

* Includes remote or on-site support from Mimoto
* Uses the official Oracle JDK
* Releases are manually checked, and given additional, more intensive tests
* Releases are signed, and available from a private repository

If you'd like more information about Ishigaki Academic Edition, please [contact Mimoto](http://mimoto.co.uk/contact/)

### Related Projects from Digital Identity

* eduLDAP - a quick and easy OpenLDAP image for HE use

### What does "ishigaki" mean?
Ishigaki are the impressive dry stone [foundation walls of Japanese castles](http://www.jcastle.info/resources/view/109-Stone-Walls).
(Ishigaki is also the name of a beautiful [island and city in Okinawa](https://en.wikipedia.org/wiki/Ishigaki_Island))

### Thanks
* Ian Young's script to test Java crypto features has been included with his kind permission
* We're just packaging huge amounts of work by [The Shibboleth Consortium](https://www.shibboleth.net/consortium/) and the wider Shibboleth community

### Contributing
You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/ishigaki/issues), or submit a [pull request](https://github.com/Digital-Identity-Labs/ishigaki/pulls) with your contribution.

If you have a support contract with Mimoto, please [contact Mimoto](http://mimoto.co.uk/contact/)

### License
Copyright (c) 2017 Digital Identity Labs

Licensed under the MIT License
