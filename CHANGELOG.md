# Changelog

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
