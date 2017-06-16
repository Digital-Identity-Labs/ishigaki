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
    mkdir -p $JETTY_HOME && tar -zxvf jetty-distribution-9.*.tar.gz -C $JETTY_HOME --strip-components 1 && \
    rm -rf $JETTY_HOME/demo_base

COPY src $SRC_DIR
RUN mv $SRC_DIR/jetty-shib $JETTY_BASE && \
    mkdir /opt/jetty-shib/logs && chmod 0777 /opt/jetty-shib/logs



EXPOSE 8080

WORKDIR $JETTY_BASE
ENTRYPOINT java -jar $JETTY_HOME/start.jar