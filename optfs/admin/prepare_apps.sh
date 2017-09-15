#!/usr/bin/env bash

## Fail unless all env variables are set
set -u


## Carry out all steps as one command, to return a failure code if something goes wrong
reset_permissions () {
  printf "Resetting IdP's filesystem permissions... " && \
    chmod a+x $ADMIN_HOME/*.sh && \
    mkdir -p $JETTY_BASE/logs && chown -R jetty $JETTY_BASE/logs && chmod 0770 $JETTY_BASE/logs && \
    chmod 0755 $IDP_HOME/* && \
    mkdir -p $IDP_HOME/logs   && chown -R jetty $IDP_HOME/logs   && chmod 0770 $IDP_HOME/logs   && \
    chgrp -R jetty $IDP_HOME/conf/*        && chmod -R g+r $IDP_HOME/conf/* && \
    chgrp -R jetty $IDP_HOME/credentials/* && chmod -R g+r $IDP_HOME/credentials/* && \
    mkdir -p $IDP_HOME/metadata && chown -R jetty $IDP_HOME/metadata && chmod -R 0770 $IDP_HOME/metadata && \
    sync && echo "done."
}

## Rebuild IdP .war file, absorbing additional libraries, templates, etc from installation directory.
rebuild_war () {
     printf "Repackaging IdP .war file based on "
    (cd $IDP_HOME && ./bin/build.sh)
}

echo "Preparations starting..."

## Start from a known position
reset_permissions

## Additional actions, depending on options passed on commandline
for flag in "$@"
do
    case "${flag,}" in

    "rebuild")
      rebuild_war && reset_permissions
      ;;
    "rekey")
      echo  "Not implemented"
      ;;
    *)
      echo "Error - unknown prepare_apps option!"
      ;;

    esac
done

echo "Preparations complete."




