FROM tutum/curl:trusty
MAINTAINER MaLu <malu@malu.me> 

RUN curl http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' >> /etc/apt/sources.list

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install wget vim nginx-full apache2-utils supervisor && \
    apt-get install -y elasticsearch openjdk-7-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget --no-check-certificate -O- https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz | tar xvfz - 
RUN mkdir /etc/kibana # This is where the htpasswd file is placed by the run script

ADD kibana /etc/nginx/sites-available/kibana
ADD kibana-secure /etc/nginx/sites-available/kibana-secure
RUN rm /etc/nginx/sites-enabled/*
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ENV KIBANA_SECURE true
ENV KIBANA_USER malu
ENV KIBANA_PASSWORD kibanana
#ENV ES_USER malu
#ENV ES_PASS elabc

EXPOSE 80 9200

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD run ./run
RUN chmod +x ./run
CMD ./run
