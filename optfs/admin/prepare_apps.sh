#!/usr/bin/env bash

## Fail unless all env variables are set
set -u

## Carry out all steps as one command, to return a failure code if something goes wrong
mkdir -p $JETTY_BASE/logs && chown -R jetty $JETTY_BASE/logs && chmod 0770 $JETTY_BASE/logs && \
mkdir -p $IDP_HOME/logs   && chown -R jetty $IDP_HOME/logs   && chmod 0770 $IDP_HOME/logs   && \
chgrp -R jetty $IDP_HOME/conf/*        && chmod -R g+r $IDP_HOME/conf/* && \
chgrp -R jetty $IDP_HOME/credentials/* && chmod -R g+r $IDP_HOME/credentials/* && \
mkdir -p $IDP_HOME/metadata && chown -R jetty $IDP_HOME/metadata && chmod -R 0770 $IDP_HOME/metadata
