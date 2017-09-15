# Changelog

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
