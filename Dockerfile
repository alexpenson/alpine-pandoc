FROM alpine:3.6

ENV PANDOC_VERSION 2.1.3
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/archive/$PANDOC_VERSION.tar.gz
ENV PANDOC_DOWNLOAD_SHA512 b2a58f6969e55a15ddbc91d2db6d8e7e9ed1c45a3b06db45853796199d17c8b5e0f6dd32e45a3c3d04754a3a05b2294f4f5c839304021b64c8b43642d513cdf0
ENV PANDOC_ROOT /usr/local/pandoc

## Install dependencies
RUN apk add --no-cache \
    gmp \
    libffi \
 && apk add --no-cache --virtual build-dependencies \
    --repository "http://nl.alpinelinux.org/alpine/edge/community" \
    ghc \
    cabal \
    linux-headers \
    musl-dev \
    zlib-dev \
    curl \
 && apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install virtualenv panflute

## Install pandoc
RUN mkdir -p /pandoc-build && cd /pandoc-build \
 && curl -fsSL "$PANDOC_DOWNLOAD_URL" -o pandoc.tar.gz \
 && echo "$PANDOC_DOWNLOAD_SHA512  pandoc.tar.gz" | sha512sum -c - \
 && tar -xzf pandoc.tar.gz && rm -f pandoc.tar.gz \
 && ( cd pandoc-$PANDOC_VERSION && cabal update && cabal install --only-dependencies \
    && cabal configure --prefix=$PANDOC_ROOT \
    && cabal build \
    && cabal copy \
    && cd .. )

## Install filters
RUN cabal install pandoc-citeproc pandoc-crossref

## Clean up
# RUN rm -Rf pandoc-$PANDOC_VERSION/ \
#  && apk del --purge build-dependencies \
#  && rm -Rf /root/.cabal/ /root/.ghc/ \
#  && cd / && rm -Rf /pandoc-build \
#  && rm -rf /var/cache/apk/*

ENV PATH $PATH:$PANDOC_ROOT/bin
RUN mkdir -p /var/docs
WORKDIR /var/docs
