FROM alpine:3.22

# set some defaults
ENV AWS_DEFAULT_REGION="us-east-1"
ENV KUBECTL_VER=v1.33.4

RUN apk --no-cache upgrade
RUN apk --no-cache add --update bash ca-certificates git groff python3 jq aws-cli

RUN apk --no-cache add \
        binutils \
        curl \
    && curl -L "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && apk --no-cache del \
        binutils \
        curl \
    && rm -rf /var/cache/apk/*

CMD ["bash"]
