FROM bitnami/minideb:bookworm

LABEL description="A small, elegant foundation image for Shibboleth IdP containers" \
      maintainer="pete@digitalidentitylabs.com" \
      org.opencontainers.image.source="https://github.com/Digital-Identity-Labs/ishigaki"

ARG SRC_DIR=/usr/local/src
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ARG JETTY_URL=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/11.0.17/jetty-home-11.0.17.tar.gz
ARG JETTY_CHECKSUM=a3c6151880119ea623a91ac797fa6dd92d7bbae9
#ARG IDP_URL=https://shibboleth.net/downloads/identity-provider/5.0.0/shibboleth-identity-provider-5.0.0.tar.gz
ARG IDP_URL=https://f002.backblazeb2.com/file/mimoto-mirror/shibboleth-identity-provider-5.0.0.tar.gz
ARG IDP_CHECKSUM=7e782a0e82d01d724b4889700d4db603b17d9a912b21f7c0fcedf18527f9efff
ARG DTA_URL=https://build.shibboleth.net/nexus/content/repositories/releases/net/shibboleth/utilities/jetty9/jetty94-dta-ssl/1.0.0/jetty94-dta-ssl-1.0.0.jar
ARG DTA_CHECKSUM=5e5de66e3517d30ff19ef66cf7a4aa5443b861d83e36a75e85845b007a03afbf
ARG EDWIN_STARR=0
ARG DELAY_WAR=0

ARG IDP_HOSTNAME=idp.example.com
ARG IDP_ID=https://idp.example.com/idp/shibboleth
ARG IDP_SCOPE=example.com
ARG IDP_KEYSIZE=3072
ARG SPASS=password
ARG KPASS=password
ARG CREDS_MODE=640
ARG CREDS_GROUP=jetty
ARG IDP_PROPERTIES=""
ARG JETTY_UID=5101
ARG JETTY_GID=$JETTY_UID
ARG MODULES="idp.authn.Password,idp.admin.Hello"
ARG DISABLE_MODULES=""
ARG PLUGINS=""
ARG PLUGIN_IDS=""
ARG PLUGIN_MODULES=""
ARG IDP_PROPERTIES=""
ARG IDP_PROPERTIES_FILE="$SRC_DIR/idp.properties"
ARG LDAP_PROPERTIES=""
ARG LDAP_PROPERTIES_FILE="$SRC_DIR/ldap.properties"
ARG INSTALL_PROPERTIES="idp.keysize=$IDP_KEYSIZE\nidp.keystore.password=$KPASS\nidp.sealer.password=$SPASS\nidp.initial.modules=$MODULES\nldap.merge.properties=$LDAP_PROPERTIES_FILE\nidp.merge.properties=$IDP_PROPERTIES_FILE\n"
ARG INSTALL_PROPERTIES_FILE="$SRC_DIR/install.properties"

ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto \
    JETTY_HOME=/opt/jetty \
    JETTY_BASE=/opt/jetty-shib \
    ADMIN_HOME=/opt/admin \
    IDP_HOME=/opt/shibboleth-idp \
    CREDS_GROUP=$CREDS_GROUP \
    WRITE_MD=1 \
    IDP_BASE_URL=localhost:8080/idp

WORKDIR $SRC_DIR

COPY aptfs .

## Install Java and other OS-level packages
RUN apt-get update && apt-get upgrade && \
    install_packages gnupg curl unzip procps net-tools gosu ca-certificates && \
    cat corretto.key | gpg --dearmor > /etc/apt/trusted.gpg.d/corretto.gpg && \
    cp sources.list /etc/apt/ && \
    install_packages java-17-amazon-corretto-jdk && \
    rm -rfv $JAVA_HOME/lib/*.zip && \
    apt-get remove --auto-remove --yes --allow-remove-essential gnupg dirmngr unzip && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /usr/local/src/*

## Install Jetty from source
RUN curl -o jetty.tgz $JETTY_URL && \
    echo "${JETTY_CHECKSUM} jetty.tgz" > jetty.tgz.sha1 && sha1sum -c jetty.tgz.sha1 && \
    mkdir -p $JETTY_HOME && tar -zxf jetty.tgz -C $JETTY_HOME --strip-components 1 && \
    groupadd --gid $JETTY_GID jetty && \
    useradd --gid $JETTY_GID --uid $JETTY_UID --shell /bin/false --home-dir $JETTY_BASE jetty && \
    rm -rf $JETTY_HOME/demo-base && \
    chown -R root $JETTY_HOME && \
    mkdir -p $JETTY_BASE/tmp && chown -R jetty $JETTY_BASE/tmp && chmod 0770 $JETTY_BASE/tmp && \
    mkdir -p $JETTY_BASE/logs && chown -R jetty $JETTY_BASE/logs && chmod 0770 $JETTY_BASE/logs && \
    curl -L -o jetty94-dta-ssl-1.0.0.jar $DTA_URL && \
    echo "${DTA_CHECKSUM} jetty94-dta-ssl-1.0.0.jar" > jetty94-dta-ssl-1.0.0.jar.sha256 && sha256sum -c jetty94-dta-ssl-1.0.0.jar.sha256 && \
    mkdir -p $JETTY_BASE/lib/ext && \
    cp jetty94-dta-ssl-1.0.0.jar $JETTY_BASE/lib/ext/ && \
    (cd $JETTY_BASE && java -jar $JETTY_HOME/start.jar --add-module=logging-logback,requestlog --approve-all-licenses) && \
    rm -rf /usr/local/src/*

## Install the Shibboleth IdP software from source
RUN curl -o idp.tgz $IDP_URL && \
    echo "${IDP_CHECKSUM} idp.tgz" > idp.tgz.sha256 && sha256sum -c idp.tgz.sha256
RUN mkdir -p idp_src && tar -zxf idp.tgz -C idp_src --strip-components 1 && \
    rm -rf idp_src/bin/*.bat && \
    echo $IDP_PROPERTIES  > $IDP_PROPERTIES_FILE && \
    echo $LDAP_PROPERTIES > $LDAP_PROPERTIES_FILE && \
    echo $INSTALL_PROPERTIES > $INSTALL_PROPERTIES_FILE && \
    idp_src/bin/install.sh \
    --targetDir $IDP_HOME \
    --noPrompt true\
    --propertyFile $INSTALL_PROPERTIES_FILE \
    --hostName $IDP_HOSTNAME \
    --scope $IDP_SCOPE \
    --entityID $IDP_ID \
    --keystorePassword $KPASS \
    --sealerPassword $SPASS && \
    mkdir -p /var/opt/shibboleth-idp/tmp && chown -R jetty /var/opt/shibboleth-idp/tmp && \
    if [ "${WRITE_MD}" -gt "0" ] ; then mkdir -p $IDP_HOME/metadata && chown -R jetty $IDP_HOME/metadata ; fi && \
    mkdir -p $IDP_HOME/metadata/local && chown -R root:root $IDP_HOME/metadata/local && \
    mkdir -p $IDP_HOME/metadata/bilateral && chown -R root:root $IDP_HOME/metadata/bilateral && \
    mkdir -p $IDP_HOME/metadata/federated && chown -R root:$CREDS_GROUP $IDP_HOME/metadata/federated && \
    mkdir -p $IDP_HOME/metadata/override && chown -R root:$CREDS_GROUP $IDP_HOME/metadata/override && \
    chmod -R g+w $IDP_HOME/metadata/federated && \
    mkdir -p $IDP_HOME/logs && chown -R jetty $IDP_HOME/logs && chmod 0770 $IDP_HOME/logs && \
    chgrp -R $CREDS_GROUP $IDP_HOME/credentials/* && chmod $CREDS_MODE $IDP_HOME/credentials/* && \
    mkdir $ADMIN_HOME && \
    rm -rf /usr/local/src/* && \
    if [ "${EDWIN_STARR}" -gt "0" ] || [ "${DELAY_WAR}" -gt "0" ] ; then rm -fv $IDP_HOME/war/* ; fi

## Install plugins and modules
COPY plugins $SRC_DIR/plugins
RUN cp -r $SRC_DIR/plugins/truststores/* $IDP_HOME/credentials && \
    echo "\nOfficial Plugins Available: " && $IDP_HOME/bin/plugin.sh -L && \
    /bin/bash -c 'if [[ ! -z "${MODULES}" ]] ; then $IDP_HOME/bin/module.sh -i $MODULES ; $IDP_HOME/bin/module.sh -e $MODULES ; fi' && \
    /bin/bash -c 'if [[ ! -z "${DISABLE_MODULES}" ]] ; then $IDP_HOME/bin/module.sh -d $DISABLE_MODULES ; fi' && \
    for plugin in $PLUGINS; do $IDP_HOME/bin/plugin.sh -i $plugin ; done && \
    for plugin in $PLUGIN_IDS; do $IDP_HOME/bin/plugin.sh -I $plugin ; done && \
    /bin/bash -c 'if [[ ! -z "${PLUGIN_MODULES}" ]] ; then $IDP_HOME/bin/module.sh -i $PLUGIN_MODULES ; $IDP_HOME/bin/module.sh -e $PLUGIN_MODULES ; fi' && \
    echo "\nPlugins Status: " && $IDP_HOME/bin/plugin.sh -l && \
    echo "\nModules Status: " && $IDP_HOME/bin/module.sh -l && \
    /bin/bash -c 'if [ "${EDWIN_STARR}" -gt "0" ] ; then rm -fv $IDP_HOME/war/* ; fi'

COPY optfs /opt

EXPOSE     8080
WORKDIR    $JETTY_BASE

ENTRYPOINT exec gosu jetty:$CREDS_MODE $(/usr/bin/java -jar ${JETTY_HOME}/start.jar --dry-run)

HEALTHCHECK --interval=30s --timeout=3s CMD curl -A "Ishigaki Healthcheck" -f ${IDP_BASE_URL}/status || exit 1
