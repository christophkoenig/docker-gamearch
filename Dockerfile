# build stage
FROM ubuntu:focal AS builder

ARG REPO=https://github.com/Cryptec/GameArch.git
ARG BRANCH=main
ENV TZ=Europe/Berlin

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    mkdir /data && \
    apt update -y && \
    apt upgrade -y && \
    apt install -y git curl

# node and yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x -o /data/nodesource_setup.sh && \
    bash /data/nodesource_setup.sh && \
    rm /data/nodesource_setup.sh && \
    apt install -y nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install --no-install-recommends yarn

# app
RUN git clone -b ${BRANCH} ${REPO} /data/GameArch

COPY build/platforms.js /data/GameArch/Frontend/src/utils/

RUN cd /data/GameArch/Frontend && \
    yarn install && \
    yarn build && \
    cd /data/GameArch/Backend && \
    yarn install

# production stage
FROM ubuntu:focal

ARG BUILD_DATE
ARG VERSION
ARG S6_OVERLAY_VERSION=3.1.0.1
ENV TZ=Europe/Berlin

LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.authors="christophkoenig"
LABEL org.opencontainers.image.version=${VERSION}

# add s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp

# install necessary packages & init settings
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    mkdir /data && \
    mkdir -p /usr/share/nginx/html && \
    apt update -y && \
    apt upgrade -y && \
    apt install -y curl nginx && \
    curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh && \
    bash /tmp/nodesource_setup.sh && \
    apt install -y nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install --no-install-recommends yarn && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -rf /tmp/*

WORKDIR /data

# copy backend and frontend assets
COPY --from=builder /data/GameArch/Backend .
COPY --from=builder /data/GameArch/Frontend/build /usr/share/nginx/html

RUN rm -rf node_modules && \
    yarn install --frozen-lockfile && \
    yarn cache clean

# copy nginx and s6 config files
COPY root/ /

WORKDIR /app

COPY build/.env.frontend ./.env
COPY build/env.sh .
COPY build/prepare-nginx.sh .

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

ENTRYPOINT ["/init"]