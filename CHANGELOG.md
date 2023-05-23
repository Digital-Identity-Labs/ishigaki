# Changelog

## 3.0.0 - 2023-05-23

A major update with potentially breaking changes - Linux, Shibboleth IdP, Java and Jetty are all new.

## Improvements
- Shibboleth IdP updated to latest stable release: v4.3.1
- Jetty 10 and simplified Jetty configuration: You will need to rewrite any existing customisation of Jetty configuration 
- Java updated to Corretto JDK 17
- Linux updated to Debian 11 (Bullseye)
- Updated plugin trust keys
- New `PLUGIN_IDS` build argument to add official modules by ID, rather than file or URL
- `jetty94-dta-ssl-1.0.0.jar` is included by default so with additional configuration both TLS and backchannel can be supported
- Jetty request logging to STDOUT is active 
- LogBack .jars are included, and LogBack enabled
- Jetty no longer forks on startup, saving about 120MB of RAM
- Jetty's ugly default favicon is replaced by a nicer Shibboleth logo (but please replace that with your own!)
- Static web files are now at `/opt/jetty-shib/static`
- Tests are now using [Cinc Auditor](https://cinc.sh/start/auditor/) and always update before running

## Fixes
- Build-time installation of plugins has been fixed
- Jetty `tmp/` has been moved to `/opt/jetty-shib/tmp` from JETTY_HOME

## 2.2.1

### Fixes
- `prepare_apps.sh rebuild` now explicitly sets installer idp.home using the $IDP_HOME environment variable. It's still deprecated though.

## 2.2.0

Minor updates to the Shibboleth IdP and Jetty software

### Improvements
- Uses Shibboleth 4.1.4 (bug fixes and minor changes)
- Uses Jetty 9.4.43 (more bug fixes)
- Latest OIDC Plugin versions are downloaded for 'plus' edition

## 2.1.0

Corrects an issue where the filesystem uid and gid may be unpredictable and cause issues when mounting volumes directly.
To maintain normal security permissions on mounted credentials you can either create a local user with these IDs, or
use user mapping. 

### Improvements
- On build UID and GID of the jetty process can be set using build arguments JETTY_UID and JETTY_GID, defaulting to 5101

### Fixes

- jetty group has a fixed uid and gid, determined at build-time, defaulting to 5101 to put it above auto-assigned
  uids/gids on most servers

### Tests
- Using tweaked test suite, updated to match ignore the plugins directory in /usr/local/src when checking if it's tidy

## 2.0.0

Another significant update, with a new IdP and new Dockerfile features. The updated IdP brings plugin and module functionality, and the new Dockerfile is much more useful for building bespoke images.

### Improvements

- Uses Shibboleth IdP v4.1.0: **This is a breaking change - configuration files will need to be replaced or upgraded**. Please read [the release notes for v4.1.0](https://wiki.shibboleth.net/confluence/display/IDP4/ReleaseNotes#ReleaseNotes-4.1.0(March24,2021))
- Jetty has been updated to v9.4.40  
- The Dockerfile can be used to active or deactivate modules when building a new image
- The Dockerfile can be used to build IdPs including plugins when building a new image
- More installer settings can be configured using the Dockerfile
- `rake build:base` builds a minimal image for use a base image 
- `rake build:plus` builds an image with OIDC, TOTP and Javascript plugins
- `rake build:all` builds default, plus and base images
- `rake export` copies the configuration out of the default image
- The new plugins directory can be used to install plugin archives (local or remote) and truststores during a build

### Deprecations
- The `prepare_apps.sh` script is now deprecated and is (fingers crossed)  no longer needed. The Shibboleth IdP installer will now set the correct permissions on credentials, and `bin/build.sh` 
  should be used to rebuild the .war.

### Releases
- Travis is no longer used as a CI to build Ishigaki images
- Images are now available from Github as well as from Dockerhub. Only the default image is available at Docker Hub.

### Tests
- Using tweaked test suite, updated to match new IdP version.

### Known Issues
- The new images are now considerably larger (especially the plus version)

## 1.1.0

### Improvements

- Jetty no longer sets `-Xmx1500m` as a JVM option so that memory usage can be controlled  using Docker's `--memory` option or Docker Compose's `deploy: resource:` settings. The previous behaviour can be restored by copying a tweaked start.ini to /opt/jetty-shib/

## 1.0.0

### Improvements

- Uses Shibboleth IdP v4.0.1: **This is a breaking change - configuration files will need to be replaced or upgraded**. Please read [the release notes for v4.0.0](https://wiki.shibboleth.net/confluence/display/IDP4/ReleaseNotes#ReleaseNotes-4.0.0(March11,2020)) 
- Switched from Zulu 8 JDK to Amazon's Corretto 11 JDK
- Jetty bumped to 9.4.32 (bug fixes)
- Initial secrets can be passed with build arguments
- EDWIN_STARR build argument switch for when a .war is good for absolutely nothing
- Improved and simplified Dockerfile

### Fixes
- Messages during Docker build now work correctly
- Logging configuration ignores spurious Status.vm error messages

### Tests

- Using new version of test suite, updated to match new environment and IdP version

## 0.4.9

### Improvements

- Jetty 9.4.24 (patch release with various bug fixes)

## 0.4.8

### Improvements

- Shibboleth IdP 3.4.6 (various bug fixes)
- Jetty 9.4.21 (also just a patch release)

## 0.4.7

### Improvements

- Using Shibboleth IdP 3.4.5 (various bug fixes and a potential data-leak fix)

## 0.4.6

### Improvements

- Using Jetty 9.4.20
- Based on Debian 10 Buster (via MiniDeb)

## 0.4.5

### Improvements

- Using Jetty 9.4.18 rather than 9.4.15
- Shibboleth IdP updated to 3.4.4 (new LDAP driver option and bug fixes)

## 0.4.4


### Improvements

- Using Jetty 9.4.15 rather than 9.4.11
- Updated test libraries

### Fixes

- No longer refering to Debian 8 backport packages (since OS is Debian 9)

## 0.4.3

### Fixes

- Shibboleth IdP updated to 3.4.3 (no functionality changes, just bug fixes)

## 0.4.2

### Fixes

- Shibboleth IdP updated to 3.4.2

## 0.4.1

### Fixes

- Update IdP to 3.4.1 (a bugfix patch release)
- Use latest version of inSpec for tests (3.0.n)

## 0.4.0

### Improvements

- Shibboleth IdP updated to 3.4.0 (including quite a few new features)

### Tests

- Tests no longer check the permissions on the webapp directory, as it's gone.

## 0.3.4

### Improvements

- Jetty updated to 9.4.11

## 0.3.3

### Fixes

- Updated to Shibboleth 3.3.3, which contains a fix for a CAS vulnerability

## 0.3.2

### Tests

- Moved all inSpec tests over to their own repo. They can now be resused by other Ishigaki-based projects. 

## 0.3.1

### Fixes

- Ruby version fixed (changed to 2.4) in Travis CI build config (it was incorrectly at 2.2)

## 0.3.0

### Improvements

- Shibboleth IdP [updated to 3.3.2](https://wiki.shibboleth.net/confluence/display/IDP30/ReleaseNotes#ReleaseNotes-3.3.2(October4,2017)), which fixes a security bug in LDAP library and updates Duo support 
- Jetty is updated too, to [9.4.7.v20170914](https://github.com/eclipse/jetty.project/releases/tag/jetty-9.4.7.v20170914), a bugfix release.

## 0.2.0

### Improvements

- The `prepare_apps.sh` script now has a "rebuild" option that will
  rebuild the IdP's .war file, using files in edit-webapp.

## 0.1.6

### Fixes

- The Dockerfile USER now stays as root, so no need to switch to root and back to jetty in
  your own images. Jetty continues to run as the jetty user.
- Jetty should receive signals properly (or at least better than before). This means
  shutdown is much faster and cleaner.

### Documentation

- Added badges to the Readme file
- Added warnings about overwriting prepare_apps.sh to the documentation
- Adjusted the example Dockerfile now that switching users is not needed

### Known Bugs
- One test has been disabled since netstat no longer names the jetty process properly.

## 0.1.5

### Fixes

- Turning off the JVM's silly default DNS caching. It's always a pain
  but with Docker it's much worse.

## 0.1.4

### Fixes

- Now works correctly with reverse proxies (config file was in wrong directory!)
- Snapshot name is consistent with released image name
- Also 14MB smaller (Jetty demo files have been removed)

## 0.1.3

- Scripts to deploy image to Docker Hub

## 0.1.2

### Features
- Created /var/cache/shibboleth-idp directory for storing file caches of remote data

### Fixes
- Fixed tests for removable Java JDK directories

## 0.1.1

### Fixes
- Shibboleth IdP directories now have same permissions when image is built on Linux and Mac
- Development branch builds on Travis correctly

## 0.1.0

### Initial release
