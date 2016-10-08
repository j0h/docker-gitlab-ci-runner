FROM alpine:latest

ENV PYTHON_MAJOR_VERSION=3
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.7.0

ENV PACKAGES="\
  build-base \
  git \
  bash \
  ca-certificates \
  python${PYTHON_MAJOR_VERSION} \
  python${PYTHON_MAJOR_VERSION}-dev \
  clang \
  openssh \
  curl \
  sudo \
  gnupg \
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


RUN set -ex \
    && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs


COPY ./ /usr/bin
