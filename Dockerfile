FROM alpine:latest

# Set versions
ARG GCLOUD_VERSION=269.0.0
ARG CONSUL_VERSION=1.5.0

# Install required packages
RUN apk --no-cache add curl ca-certificates python bash py-yaml gettext

# Install the Googles
RUN curl -LO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
RUN tar xvfz /google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz; rm /google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz
RUN ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
RUN ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil

# Install the Consuls 
RUN curl -LO https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip 
RUN unzip consul_${CONSUL_VERSION}_linux_amd64.zip
RUN mv consul /usr/local/bin

# Instal the Startups
COPY entrypoint.yaml /
COPY docker-entrypoint.py /
COPY startup.sh /

RUN chmod +x /startup.sh
RUN chmod +x /docker-entrypoint.py

ENTRYPOINT ["/docker-entrypoint.py"]

CMD ["/startup.sh"]
