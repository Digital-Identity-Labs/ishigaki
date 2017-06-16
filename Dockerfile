FROM bitnami/minideb:latest

LABEL maintainer "pete@digitalidentitylabs.com"

ENV JAVA_HOME=/usr/lib/jvm/zulu-8-amd64 JETTY_HOME=/opt/jetty JETTY_BASE=/opt/jetty-shib SRC_DIR=/usr/local/src \
    JCE_URL=http://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip JCE_CHECKSUM="ebe83e1bf25de382ce093cf89e93a944" \
    JETTY_URL=http://central.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.6.v20170531/jetty-distribution-9.4.6.v20170531.tar.gz \
    JETTY_CHECKSUM=a99c534c5029127cd2f78c666e0910fd


WORKDIR $SRC_DIR



RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 && \
    echo "deb http://repos.azulsystems.com/debian stable  main" >> /etc/apt/sources.list.d/zulu.list && \
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/backports.list && \
    install_packages zulu-8 curl unzip
RUN curl -O $JCE_URL && md5sum ZuluJCEPolicies.zip | grep $JCE_CHECKSUM
RUN unzip ZuluJCEPolicies.zip && mv ZuluJCEPolicies/*.jar /usr/lib/jvm/zulu-8-amd64/jre/lib/security/ && \
    echo "By using this software you agree to http://www.azul.com/products/zulu/zulu-terms-of-use/"

RUN curl -O $JETTY_URL && md5sum jetty-distribution-9.4.6.v20170531.tar.gz | grep $JETTY_CHECKSUM && \
    mkdir -p $JETTY_HOME && tar -zxf jetty-distribution-9.*.tar.gz -C $JETTY_HOME --strip-components 1 && \
    rm -rf $JETTY_HOME/demo_base

ENV IDP_URL=https://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-3.3.1.tar.gz \
    IDP_CHECKSUM=80ddc32401fe3b5b9e0e04ae2f11dd73 IDP_HOME=/opt/shibboleth-idp

RUN curl -k -O  $IDP_URL && md5sum shibboleth-identity-provider-3.*.tar.gz | grep $IDP_CHECKSUM  && \
    mkdir -p idp_src && tar -zxf shibboleth-identity-provider-3.*.tar.gz -C idp_src --strip-components 1



COPY src $SRC_DIR
RUN mv $SRC_DIR/jetty-shib $JETTY_BASE && \
    mkdir /opt/jetty-shib/logs && chmod 0777 /opt/jetty-shib/logs




EXPOSE 8080

WORKDIR $JETTY_BASE
ENTRYPOINT java -jar $JETTY_HOME/start.jar