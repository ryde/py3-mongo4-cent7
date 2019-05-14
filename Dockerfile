FROM local/c7-systemd
LABEL maintainer="ryde <masakio@post.kek.jp>"

ADD ./mongodb-org-4.0.repo /etc/yum.repos.d/
ADD ./disable-transparent-hugepages /etc/init.d/

RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
    yum install -y python36u python36u-libs python36u-devel python36u-pip python36u-mod_wsgi && \
    ln -s /bin/python3.6 /bin/python3 && \
    ln -s /bin/pip3.6 /bin/pip3 && \
    pip3 install -U pip && \
    yum install -y git2u mongodb-org && \
    yum clean all

RUN chmod 755 /etc/init.d/disable-transparent-hugepages && \
    chkconfig --add disable-transparent-hugepages && \
    mkdir -p /usr/local/mongodb/conf && \
    openssl rand -base64 741 > /usr/local/mongodb/conf/mongodb-keyfile && \
    chmod 600 /usr/local/mongodb/conf/mongodb-keyfile && \
    chown -R mongod.mongod /usr/local/mongodb/conf/mongodb-keyfile

RUN sed -i -e "/^#security:/c\security:" /etc/mongod.conf && \
    sed -i -e "/^security/a \  authorization: enabled" /etc/mongod.conf && \
    sed -i -e "/^security/a \  keyFile: /usr/local/mongodb/conf/mongodb-keyfile" /etc/mongod.conf

RUN systemctl enable mongod.service

EXPOSE 27017

CMD ["/usr/sbin/init"]