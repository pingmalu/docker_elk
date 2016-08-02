FROM tutum/curl:trusty
MAINTAINER MaLu <malu@malu.me> 

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' >> /etc/apt/sources.list

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install wget vim nginx-full apache2-utils supervisor ssh && \
    apt-get install -y elasticsearch openjdk-7-jre-headless

RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

RUN wget https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.3.4-1_all.deb && \
    dpkg -i logstash_2.3.4-1_all.deb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget --no-check-certificate -O- https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz | tar xvfz - 
RUN mkdir /etc/kibana # This is where the htpasswd file is placed by the run script
RUN mkdir /opt/log

RUN rm /etc/nginx/sites-enabled/*
ADD kibana /etc/nginx/sites-available/kibana
ADD kibana-secure /etc/nginx/sites-available/kibana-secure
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ENV KIBANA_SECURE true
ENV KIBANA_USER malu
ENV KIBANA_PASSWORD kibanana
#ENV ES_USER malu
#ENV ES_PASS espass

ADD set_root_pw.sh /set_root_pw.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/opt/log"]

EXPOSE 80 9200 22

ADD run ./run
RUN chmod +x ./run
RUN chmod +x /set_root_pw.sh
CMD ./run
