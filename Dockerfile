FROM alpine:latest

ENV NODE_VERSION=v6.3.0 NPM_VERSION=3
ENV PYTHON_MAJOR_VERSION=3

ENV PACKAGES="\
  build-base \
  git \
  bash \
  ca-certificates \
  python${PYTHON_MAJOR_VERSION} \
  python${PYTHON_MAJOR_VERSION}-dev \
  clang \
  openssh \
"

RUN echo \
  && if [[ "$PYTHON_MAJOR_VERSION" == '2' ]]; then PACKAGES="$(echo $PACKAGES | sed -e 's/python2/python/g')"; fi \

  && echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && apk add --no-cache $PACKAGES || \
    (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \

  && if [[ ! -e /usr/bin/python ]];        then ln -sf /usr/bin/python${PYTHON_MAJOR_VERSION} /usr/bin/python; fi \
  && if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python-config${PYTHON_MAJOR_VERSION} /usr/bin/python-config; fi \

  && if [[ ! -e /usr/bin/idle ]];          then ln -sf /usr/bin/idle${PYTHON_MAJOR_VERSION} /usr/bin/idle; fi \
  && if [[ ! -e /usr/bin/pydoc ]];         then ln -sf /usr/bin/pydoc${PYTHON_MAJOR_VERSION} /usr/bin/pydoc; fi \

  && if [[ ! -e /usr/bin/easy_install ]];  then ln -sf /usr/bin/easy_install-${PYTHON_MAJOR_VERSION}.* /usr/bin/easy_install; fi \

  && easy_install pip \
  && pip install --upgrade pip \

  && if [[ ! -e /usr/bin/pip ]];           then ln -sf /usr/bin/pip${PYTHON_MAJOR_VERSION} /usr/bin/pip; fi \

&& echo

RUN apk upgrade --update && \
    apk add --update git curl make gcc g++ python linux-headers libgcc libstdc++ && \
    curl -sSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz | tar -xz && \
    cd /node-${NODE_VERSION} && \
    ./configure --prefix=/usr --without-snapshot && \
    make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    make install && \
    cd / && \
    npm install -g npm@${NPM_VERSION} && \
    apk del gcc g++ linux-headers && \
    rm -rf /etc/ssl /node-${NODE_VERSION} /usr/include \
    /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html

COPY ./ /usr/bin
