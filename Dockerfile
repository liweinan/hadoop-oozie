FROM alpine
MAINTAINER l.weinan@gmail.com

# install dev tools
RUN apk --no-cache add curl which tar sudo rsync openssh zip unzip bash openjdk8 wget maven git tree
# https://github.com/gliderlabs/docker-alpine/issues/397
RUN apk --no-cache add busybox-extras
# http://www.iops.cc/make-splunk-docker-w
RUN apk --no-cache add --update procps

# Download Oozie sources
ADD https://github.com/apache/oozie/archive/release-4.2.0.tar.gz /root/
RUN cd /root && tar xfv release-4.2.0.tar.gz && rm release-4.2.0.tar.gz

# Patch Oozie webapp pom.xml
ADD oozie-4.2.0-webapp-pom.xml.patch /root/oozie-release-4.2.0/webapp/
RUN cd /root/oozie-release-4.2.0/webapp && patch pom.xml oozie-4.2.0-webapp-pom.xml.patch

RUN mkdir -p /opt

ARG HADOOP_VER=2.7.2
# Build Oozie. A single RUN because maven dependencies would inflate this layer to gigabytes
RUN cd /root/oozie-release-4.2.0 \
   && export PATH=/root/apache-maven-3.3.3/bin:$PATH \
   && mvn -q clean package assembly:single -DskipTests -P hadoop-2,uber -Dhadoop.version=${HADOOP_VER} \
   && mv /root/oozie-release-4.2.0/distro/target/oozie-4.2.0-distro.tar.gz /opt/ && cd /opt && tar xfv oozie-4.2.0-distro.tar.gz && rm oozie-4.2.0-distro.tar.gz \
   && rm -fR /root/oozie-release-4.2.0 \
   && rm -fR /root/.m2

RUN mkdir -p /var/log/oozie
RUN mkdir -p /var/lib/oozie/data
RUN ln -s /var/log/oozie /opt/oozie-4.2.0/log
RUN ln -s /var/lib/oozie/data /opt/oozie-4.2.0/data
#
RUN mkdir -p /opt/oozie-4.2.0/libext
ADD http://archive.cloudera.com/gplextras/misc/ext-2.2.zip /opt/oozie-4.2.0/libext/
RUN /opt/oozie-4.2.0/bin/oozie-setup.sh prepare-war

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /
RUN chmod a+x /wait-for-it.sh

COPY postrun.sh /
COPY workflow.properties /root
COPY oozie-site.xml.fragment /tmp
COPY core-site.xml /opt/oozie-4.2.0/conf/hadoop-conf

RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa

RUN cd /opt/oozie-4.2.0 && tar zxvf oozie-examples.tar.gz
RUN sed -ie 's/nameNode=.*/nameNode=hdfs:\/\/hadoop:9000/' /opt/oozie-4.2.0/examples/apps/map-reduce/job.properties
RUN sed -ie 's/jobTracker=.*/jobTracker=hadoop:8032/' /opt/oozie-4.2.0/examples/apps/map-reduce/job.properties

# COPY hadoop-conf.tgz /opt
# RUN cd /opt && tar zxvf hadoop-conf.tgz

CMD ["/postrun.sh"]

RUN apk --no-cache add vim

# Oozie web ports ( API; admin ui )
EXPOSE 11000 11001

ENV PATH $PATH:/opt/oozie-4.2.0/bin
ENV OOZIE_URL "http://localhost:11000/oozie"
