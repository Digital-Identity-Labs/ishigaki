FROM bitnami/minideb:bullseye

LABEL description="A small, elegant foundation image for Shibboleth IdP containers" \
      maintainer="pete@digitalidentitylabs.com" \
      org.opencontainers.image.source="https://github.com/Digital-Identity-Labs/ishigaki"

ARG SRC_DIR=/usr/local/src
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ARG JETTY_URL=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/10.0.15/jetty-home-10.0.15.tar.gz
ARG JETTY_CHECKSUM=a43c0bda4322f2c80be574d835f51488f3832a4d
ARG IDP_URL=https://shibboleth.net/downloads/identity-provider/archive/4.3.1/shibboleth-identity-provider-4.3.1.tar.gz
ARG IDP_CHECKSUM=04d08d324a5a5f016ca69b96dbab58abbb5b3e0045455cc15cf0d33ffd6742d5
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
ARG CREDS_MODE=660
ARG CREDS_GROUP=jetty
ARG IDP_PROPERTIES=""
ARG JETTY_UID=5101
ARG JETTY_GID=$JETTY_UID
ARG IDP_PROPERTIES_FILE="$SRC_DIR/idp.properties"
ARG LDAP_PROPERTIES=""
ARG LDAP_PROPERTIES_FILE="$SRC_DIR/ldap.properties"
ARG MODULES="idp.authn.Password,idp.admin.Hello"
ARG PLUGINS=""
ARG PLUGIN_IDS=""
ARG PLUGIN_MODULES=""

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

RUN echo "\n## Installing Java and other OS packages..." > /dev/stdout && \
    apt-get update && apt-get upgrade && \
    install_packages gnupg curl unzip procps net-tools gosu ca-certificates && \
    apt-key add corretto.key && \
    cp sources.list /etc/apt/ && \
    install_packages java-17-amazon-corretto-jdk && \
    rm -rfv $JAVA_HOME/lib/*.zip && \
    apt-get remove --auto-remove --yes --allow-remove-essential gnupg dirmngr unzip && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /usr/local/src/*

RUN echo "\n## Installing Jetty from source..." > /dev/stdout && \
    curl -o jetty.tgz $JETTY_URL && \
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

RUN echo "\n## Installing Shibboleth IdP from source..." > /dev/stdout && \
    curl -o idp.tgz $IDP_URL && \
    echo "${IDP_CHECKSUM} idp.tgz" > idp.tgz.sha256 && sha256sum -c idp.tgz.sha256 && \
    mkdir -p idp_src && tar -zxf idp.tgz -C idp_src --strip-components 1 && \
    rm -rf idp_src/bin/*.bat && \
    echo $IDP_PROPERTIES  > $IDP_PROPERTIES_FILE && \
    echo $LDAP_PROPERTIES > $LDAP_PROPERTIES_FILE && \
    idp_src/bin/install.sh \
      -Didp.src.dir=$SRC_DIR/idp_src \
      -Didp.target.dir=$IDP_HOME \
      -Didp.entityID=$IDP_ID \
      -Didp.keysize=$IDP_KEYSIZE \
      -Didp.host.name=$IDP_HOSTNAME \
      -Didp.scope=$IDP_SCOPE \
      -Didp.keystore.password=$KPASS \
      -Didp.sealer.password=$SPASS \
      -Didp.conf.credentials.filemode=$CREDS_MODE \
      -Didp.conf.credentials.group=$CREDS_GROUP \
      -Dldap.merge.properties=$LDAP_PROPERTIES_FILE \
      -Didp.merge.properties=$IDP_PROPERTIES_FILE \
      -Didp.initial.modules=$MODULES \
      -Didp.noprompt=true && \
    mkdir -p /var/opt/shibboleth-idp/tmp && chown -R jetty /var/opt/shibboleth-idp/tmp && \
    if [ "${WRITE_MD}" -gt "0" ] ; then mkdir -p $IDP_HOME/metadata && chown -R jetty $IDP_HOME/metadata ; fi && \
    mkdir -p $IDP_HOME/metadata/local && chown -R root:root $IDP_HOME/metadata/local && \
    mkdir -p $IDP_HOME/metadata/bilateral && chown -R root:root $IDP_HOME/metadata/bilateral && \
    mkdir -p $IDP_HOME/metadata/federated && chown -R root:$CREDS_GROUP $IDP_HOME/metadata/federated && \
    mkdir -p $IDP_HOME/metadata/override && chown -R root:$CREDS_GROUP $IDP_HOME/metadata/override && \
    chmod -R g+w $IDP_HOME/metadata/federated && \
    mkdir -p $IDP_HOME/logs && chown -R jetty $IDP_HOME/logs && chmod 0770 $IDP_HOME/logs && \
    mkdir $ADMIN_HOME && \
    rm -rf /usr/local/src/* && \
    if [ "${EDWIN_STARR}" -gt "0" ] || [ "${DELAY_WAR}" -gt "0" ] ; then rm -fv $IDP_HOME/war/* ; fi

COPY plugins $SRC_DIR/plugins

RUN echo "\n## Installing Shibboleth IdP plugins and extra modules..." > /dev/stdout && \
    cp -r $SRC_DIR/plugins/truststores/* $IDP_HOME/credentials && \
    $IDP_HOME/bin/plugin.sh -L && \
    for plugin in $PLUGINS; do $IDP_HOME/bin/plugin.sh -i $plugin ; done && \
    for plugin in $PLUGIN_IDS; do $IDP_HOME/bin/plugin.sh -I $plugin ; done && \
    /bin/bash -c 'if [[ ! -z "${PLUGIN_MODULES}" ]] ; then $IDP_HOME/bin/module.sh -i $PLUGIN_MODULES ; $IDP_HOME/bin/module.sh -e $PLUGIN_MODULES ; fi' && \
    /bin/bash -c 'if [ "${EDWIN_STARR}" -gt "0" ] ; then rm -fv $IDP_HOME/war/* ; fi'

COPY optfs /opt

EXPOSE     8080
WORKDIR    $JETTY_BASE

ENTRYPOINT exec gosu jetty:$CREDS_MODE $(/usr/bin/java -jar ${JETTY_HOME}/start.jar --dry-run)

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f ${IDP_BASE_URL}/status || exit 1
