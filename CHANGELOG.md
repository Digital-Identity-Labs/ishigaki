# Changelog

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
