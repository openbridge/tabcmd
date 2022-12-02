FROM centos/systemd
MAINTAINER Thomas Spicer (thomas@openbridge.com)

ARG TABLEAU_SERVER_VERSION

ENV PATH="/opt/tableau/tabcmd/bin:${PATH}" \
    LANG=en_US.UTF-8
RUN set -x \
    && yum install epel-release -y \
    && yum update -y \
    && yum install -y \
        cronie \
        wget \
        unzip \
        curl \
        bash \
    && yum --enablerepo=epel-testing install -y \
        moreutils \
        monit \
    && cd /tmp \
    && tabPath="$(echo $TABLEAU_SERVER_VERSION | tr '-' '.')" \
    && wget https://downloads.tableau.com/esdalt/$tabPath/tableau-tabcmd-$TABLEAU_SERVER_VERSION.noarch.rpm -O /tmp/tableau-tabcmd-$TABLEAU_SERVER_VERSION.noarch.rpm \
    && yum install -y /tmp/tableau-tabcmd-$TABLEAU_SERVER_VERSION.noarch.rpm \
    && rm -rf /tmp/* \
    && tabcmd --accepteula
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod -R +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
