# Changelog

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
