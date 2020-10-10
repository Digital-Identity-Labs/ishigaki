FROM bitnami/minideb:latest

LABEL description="A small, elegant foundation image for Shibboleth IdP containers" \
      version="1.0.0" \
      maintainer="pete@digitalidentitylabs.com"

ARG SRC_DIR=/usr/local/src
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ARG JETTY_URL=https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.32.v20200930/jetty-distribution-9.4.32.v20200930.tar.gz
ARG JETTY_CHECKSUM=b7925b37e0ab6264bfbdf51a2b9167cb957c46f4
ARG IDP_URL=https://shibboleth.net/downloads/identity-provider/latest4/shibboleth-identity-provider-4.0.1.tar.gz
ARG IDP_CHECKSUM=832f73568c5b74a616332258fd9dc555bb20d7dd9056c18dc0ccf52e9292102a
ARG SPASS=password
ARG KPASS=password
ARG EDWIN_STARR=0

ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto \
    JETTY_HOME=/opt/jetty JETTY_BASE=/opt/jetty-shib \
    ADMIN_HOME=/opt/admin \
    IDP_HOME=/opt/shibboleth-idp \
    IDP_HOSTNAME=idp.example.com IDP_SCOPE=example.com IDP_ID=https://idp.example.com/idp/shibboleth

WORKDIR $SRC_DIR

COPY aptfs .

RUN echo "\n## Installing Java..." > /dev/stdout && \
    install_packages gnupg curl unzip procps net-tools gosu ca-certificates && \
    apt-key add corretto.key && \
    cp sources.list /etc/apt/ && \
    install_packages java-11-amazon-corretto-jdk && \
    rm -rfv $JAVA_HOME/lib/*.zip && \
    apt-get remove --auto-remove --yes --allow-remove-essential gnupg dirmngr unzip && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /usr/local/src/*

RUN echo "\n## Installing Jetty..." > /dev/stdout && \
    curl -o jetty.tgz $JETTY_URL && \
    echo "${JETTY_CHECKSUM} jetty.tgz" > jetty.tgz.sha1 && sha1sum -c jetty.tgz.sha1 && \
    mkdir -p $JETTY_HOME && tar -zxf jetty.tgz -C $JETTY_HOME --strip-components 1 && \
    useradd --user-group --shell /bin/false --home-dir $JETTY_BASE jetty && \
    rm -rf $JETTY_HOME/demo-base && \
    chown -R root $JETTY_HOME && \
    mkdir -p /var/opt/jetty/tmp && chown -R jetty /var/opt/jetty/tmp && \
    rm -rf /usr/local/src/*

RUN echo "\n## Installing Shibboleth IdP..." > /dev/stdout && \
    curl -o idp.tgz $IDP_URL && \
    echo "${IDP_CHECKSUM} idp.tgz" > idp.tgz.sha256 && sha256sum -c idp.tgz.sha256 && \
    mkdir -p idp_src && tar -zxf idp.tgz -C idp_src --strip-components 1 && \
    rm -rf idp_src/bin/*.bat && \
    echo "idp.entityID=$IDP_ID" > $SRC_DIR/temp.properties && \
    idp_src/bin/install.sh -Didp.src.dir=/usr/local/src/idp_src -Didp.target.dir=/opt/shibboleth-idp \
      -Didp.host.name=$IDP_HOSTNAME -Didp.scope=$IDP_SCOPE \
      -Didp.sealer.password=$SPASS -Didp.keystore.password=$KPASS \
      -Didp.noprompt=true -Didp.merge.properties=$SRC_DIR/temp.properties  && \
    mkdir -p /var/opt/shibboleth-idp/tmp && chown -R jetty /var/opt/shibboleth-idp/tmp && \
    mkdir -p /var/cache/shibboleth-idp   && chown -R jetty /var/cache/shibboleth-idp   && \
    rm -rf /usr/local/src/* && \
    if [ "${EDWIN_STARR}" -gt "0" ] ; then rm -fv $IDP_HOME/war/* ; fi

COPY optfs /opt

RUN echo "\n## Setting permissions and building IdP .war file..." > /dev/stdout && \
    chmod a+x $ADMIN_HOME/*.sh && sync && $ADMIN_HOME/prepare_apps.sh

EXPOSE     8080
WORKDIR    $JETTY_BASE

ENTRYPOINT exec gosu jetty:jetty /usr/bin/java -jar ${JETTY_HOME}/start.jar

HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8080/idp/status || exit 1