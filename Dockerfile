# Builds AWS CLI v2 from source on alpine with musl (instead of glibc)
#
# based on these comments in aws-cli issue
# https://github.com/aws/aws-cli/issues/4685#issuecomment-829600284
# https://github.com/aws/aws-cli/issues/4685#issuecomment-1094307056
FROM python:3.10-alpine as installer

RUN set -ex; \
    apk add --no-cache \
    git unzip groff \
    build-base libffi-dev cmake

ARG AWS_CLI_VERSION=2.7.27

RUN echo "nameserver 1.1.1.1" > /etc/resolv.conf || true; \
    set -eux; \
    mkdir /aws; \
    git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git /aws; \
    cd /aws; \
    sed -i'' 's/PyInstaller.*/PyInstaller==4.10/g' requirements-build.txt; \
    python -m venv venv; \
    . venv/bin/activate; \
    ./scripts/installers/make-exe

RUN set -ex; \
    unzip /aws/dist/awscli-exe.zip; \
    ./aws/install --bin-dir /aws-cli-bin; \
    /aws-cli-bin/aws --version

FROM alpine:3.16

# set some defaults
ENV AWS_DEFAULT_REGION "us-east-1"
ENV KUBECTL_VER=v0.23.10

RUN apk --no-cache upgrade
RUN apk --no-cache add --update bash ca-certificates git groff python3 jq

RUN apk --no-cache add \
        binutils \
        curl \
    && curl -L "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && apk --no-cache del \
        binutils \
        curl \
    && rm -rf /var/cache/apk/*

COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/

CMD bash