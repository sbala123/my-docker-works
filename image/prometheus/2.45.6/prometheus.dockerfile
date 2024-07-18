# Set the Docker image to use.
FROM sloopstash/base:v1.1.1

# Set label for prometheus.
LABEL maintainer="balamurugan@example.com"

# Install system packages and Supervisor.
RUN set -x \
  && yum update -y \
  && yum install -y wget vim net-tools gcc make tar git unzip sysstat tree initscripts bind-utils nc nmap \
  && yum clean all \
  && wget https://bootstrap.pypa.io/pip/2.7/get-pip.py \
  && python get-pip.py \
  && rm -f get-pip.py \
  && pip install supervisor \
  && mkdir -p /etc/supervisord.d
  

# Set environment variable.
ENV PROMETHEUS_VERSION=2.45.6

# Download and Install Prometheus.
WORKDIR /tmp
RUN set -x \
  && wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz --quiet \
  && tar -xvzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz > /dev/null

WORKDIR prometheus-${PROMETHEUS_VERSION}.linux-amd64
RUN set -x \
  && cp prometheus /usr/local/bin/ \
  && cp promtool /usr/local/bin/ 


# Create Prometheus directories and set up Supervisor.
#Create Prometheus directories
RUN set -x \
  RUN set -x \
&& mkdir /opt/prometheus \
&& mkdir /opt/prometheus/data \
&& mkdir /opt/prometheus/log \
&& mkdir /opt/prometheus/conf \
&& mkdir /opt/prometheus/script \
&& mkdir /opt/prometheus/system \
&& mkdir /opt/prometheus/console_libraries \
&& mkdir /opt/prometheus/consoles \
&& touch /opt/prometheus/system/server.pid \
&& touch /opt/prometheus/system/supervisor.ini \
&& ln -s /opt/prometheus/system/supervisor.ini /etc/supervisord.d/prometheus.ini \
&& cp -r consoles/* /opt/prometheus/consoles \
&& cp -r console_libraries/* /opt/prometheus/console_libraries \
&& cd ../ \
&& rm -rf prometheus-2.53.1.linux* \
&& history -c


# Expose Prometheus port at runtime.
EXPOSE 9090

# Set default work directory.
WORKDIR /opt/prometheus

# Add a healthcheck
HEALTHCHECK CMD wget --spider http://localhost:9090/ || exit 1
