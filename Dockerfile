ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="nathalie.casati@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl unzip libqt5core5a libqt5gui5 libqt5network5 \
    libqt5printsupport5 libqt5widgets5 libqt5x11extras5 libopenjp2-7 && \
    curl -sSOL https://github.com/davidbannon/libqt5pas/releases/download/v1.2.9/libqt5pas1_2.9-0_amd64.deb && \
    dpkg -i libqt5pas1_2.9-0_amd64.deb && \
    rm libqt5pas1_2.9-0_amd64.deb && \
    curl -sSOL https://github.com/rordenlab/MRIcroGL/releases/download/v${APP_VERSION}/MRIcroGL_linux.zip && \
    mkdir ./install && \
    unzip -q -d ./install MRIcroGL_linux.zip && \
    rm MRIcroGL_linux.zip && \
    apt-get remove -y --purge curl unzip && \  
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/MRIcroGL/MRIcroGL_QT"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/MRIcroGL/MRIcroGL_QT"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
