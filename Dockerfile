FROM ubuntu:20.04
ENV workdir /mnt/data
ENV OSMOSIS_VERSION="0.48.3"
ENV PROTOZERO_VERSION="v1.7.0"
ENV LIBOSMIUM_VERSION="v2.16.0"
ENV OSMIUM_TOOL_VERSION="v1.13.1"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install \
    build-essential \
    libboost-program-options-dev \
    libbz2-dev \
    zlib1g-dev \
    libexpat1-dev \
    cmake \
    pandoc \
    git \
    python3-pip \
    curl \
    unzip \
    wget \
    software-properties-common \
    libz-dev \
    zlib1g-dev \
    gdal-bin \
    tar \
    bzip2 \
    clang \
    default-jre \
    default-jdk \
    gradle \
    apt-utils \
    postgresql-client

# Install osmosis
RUN git clone https://github.com/openstreetmap/osmosis.git
WORKDIR osmosis
RUN git checkout ${OSMOSIS_VERSION}
RUN mkdir "$PWD"/dist
RUN ./gradlew assemble
RUN tar -xvzf "$PWD"/package/build/distribution/*.tgz -C "$PWD"/dist/
RUN ln -s "$PWD"/dist/bin/osmosis /usr/bin/osmosis
RUN osmosis --version 2>&1 | grep "Osmosis Version"

# Install osmium-tool
RUN git clone https://github.com/mapbox/protozero
RUN cd protozero && git checkout ${PROTOZERO_VERSION} && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/libosmium
RUN cd libosmium && git checkout ${LIBOSMIUM_VERSION} && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/osmium-tool
RUN cd osmium-tool && git checkout ${OSMIUM_TOOL_VERSION} && mkdir build && cd build && cmake .. && make && make install

# Install AWS and GCP cli
RUN pip3 install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

WORKDIR $workdir
