# Credit to Julien Guyomard (https://github.com/jguyomard). This Dockerfile
# is essentially based on his Dockerfile at
# https://github.com/jguyomard/docker-hugo/blob/master/Dockerfile. The only significant
# change is that the Hugo version is now an overridable argument rather than a fixed
# environment variable.

FROM docker.io/library/golang:1.23.1-alpine3.20

RUN apk add --no-cache \
    curl \
    gcc \
    g++ \
    musl-dev \
    build-base \
    libc6-compat

ARG HUGO_VERSION

RUN mkdir $HOME/src && \
    cd $HOME/src && \
    curl -L https://github.com/gohugoio/hugo/archive/refs/tags/v${HUGO_VERSION}.tar.gz | tar -xz && \
    cd "hugo-${HUGO_VERSION}" && \

    cd "hugo-v0.125.0.tar.gz" && \
    go install --tags extended

FROM docker.io/library/golang:1.23.1-alpine3.20

RUN apk add --no-cache \
    runuser \
    git \
    gcompat \
    openssh-client \
    rsync \
    npm

RUN mkdir -p /var/hugo && \
    addgroup -Sg 1000 hugo && \
    adduser -Sg hugo -u 1000 -h /var/hugo hugo && \
    chown -R hugo: /var/hugo && \
    runuser -u hugo -- git config --global --add safe.directory /src

COPY --from=0 /go/bin/hugo /usr/local/bin/hugo

WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci

USER hugo:hugo

EXPOSE 1313
