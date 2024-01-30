FROM ubuntu:18.04

ENV ACCEPT_EULA=Y
ENV DES_DATABASE_VENDOR=sqlserver
ENV DES_STREAM_VENDOR=eventhub
ENV DB_HOSTNAME="${DbHostname}"
ENV TEMN_TAFJ_JDBC_PASSWORD="${DbPassword}"
ENV TEMN_TAFJ_JDBC_USERNAME="${DbUsername}"
ENV TEMN_TAFJ_JDBC_URL="${DbURL}"
ARG DesURL
ARG DesPackage
ENV DES_DOWNLOAD_URL="https://payartefacts.blob.core.windows.net/des/data-event-streaming.zip"
ENV DES_PACKAGE="data-event-streaming.zip"
ENV TEMN_TAFJ_JDBC_DRIVER=com.microsoft.sqlserver.jdbc.SQLServerDriver
ENV TEMN_TAFJ_CACHE_KEYSTORE_OVERRIDE_PASSWORD_CLASS=com.my_bank.des.security.MyBankClientSecretProvider
ENV TEMN_TAFJ_CACHE_KEYSTORE_OVERRIDE_PASSWORD_CLASS_METHOD=getClientSecret
RUN apt-get update -y && apt-get install -y curl gnupg
RUN apt update -y && apt install -y maven
RUN apt install -y zip
RUN useradd -ms /bin/bash des
RUN usermod -G root des
USER des
ENV HOME=/home/des
#ADD des-kafka-t24.properties /
#ADD custom-init.sh /
WORKDIR $HOME
RUN curl $DES_DOWNLOAD_URL -o $DES_PACKAGE
RUN unzip $DES_PACKAGE
RUN cd artefacts && mvn clean install
WORKDIR $HOME/des-docker
RUN ["chmod", "+x", "des-tool.sh"]
RUN bash ./des-tool.sh build
#RUN cp /des-kafka-t24.properties $HOME/des-docker/src/main/resources/des-config/des-kafka-t24.properties
#RUN /custom-init.sh
ENTRYPOINT ["./des-tool.sh","install-MC"]
