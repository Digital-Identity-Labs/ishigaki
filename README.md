# Ishigaki

[![Build Status](https://travis-ci.org/Digital-Identity-Labs/ishigaki.svg?branch=master)](https://travis-ci.org/Digital-Identity-Labs/ishigaki)

## A Big Warning!
This project is **NOT** ready for production use yet.

## What is this?
A minimalist Debian-based Shibboleth IdP image. 
It's intended to be a solid foundation for other images but can also be used by mounting volumes.
This image is not a stand-alone production-ready IdP - it's meant to be used with other services to handle TLS,
 databases, LDAP, and so on. 

## Why use this?

* Modern: uses the latest Shibboleth IdP, Jetty and Debian OS.
* Small: Based on Minideb and built carefully, Ishigaki is only around 350MB
* Secure: Updated daily, nothing runs as root, and directory permissions are managed




## What does "ishigaki" mean?
Ishigaki are the impressive dry stone [foundation walls of Japanese castles](http://www.jcastle.info/resources/view/109-Stone-Walls).
(Ishigaki is also the name of an [island and city in Okinawa](https://en.wikipedia.org/wiki/Ishigaki_Island))


## Contributing
You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/ishigaki/issues), or submit a [pull request](https://github.com/Digital-Identity-Labs/ishigaki/pulls) with your contribution.

## License
Copyright (c) 2017 Digital Identity Labs

Licensed under the MIT License
