ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=openjdk
ARG BASE_TAG=11-jre-slim

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} AS base

ENV FORTIFY_INSTALL_DIR=/opt/Fortify/SCA

RUN groupadd -g 10000 fortify && \
    useradd -M -s /usr/sbin/nologin --uid 10000 -g fortify fortify

WORKDIR /sca

COPY ./installer ./

ENV PATH=${PATH}:${FORTIFY_INSTALL_DIR}/bin

RUN chmod +x *.run && \
    mv *.run fortify_sca.run && \
    ./fortify_sca.run --mode unattended && \
    rm -f /sca/* && \
    rm -rf /opt/Fortify/SCA/Samples && \
    fortifyupdate && \
    chown -R fortify:fortify ${FORTIFY_INSTALL_DIR} && \
    chmod -R o-w ${FORTIFY_INSTALL_DIR}

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV FORTIFY_INSTALL_DIR=/opt/Fortify/SCA
ENV PATH=${PATH}:${FORTIFY_INSTALL_DIR}/bin

COPY --from=base ${FORTIFY_INSTALL_DIR} ${FORTIFY_INSTALL_DIR}

# fonts-dejavu-core required for report generation
RUN apt-get update && apt-get install -y \
    fonts-dejavu-core \
    fontconfig  \
    && rm -rf /var/lib/apt/lists/* && \
    groupadd -g 10000 fortify && \
    useradd -m -s /usr/sbin/nologin --uid 10000 -g fortify fortify && \
    # Create default fortify project root directory
    mkdir /.fortify && \
    chmod 777 /.fortify

ADD --chown=fortify:fortify scan.sh /
RUN chmod +x scan.sh

USER fortify

ENV BUILD_ID=myapp \
    SOURCE_FILES=**/* \
    SCA_OPTIONS= \
    FPR_FILE=results.fpr

WORKDIR /src

CMD ["/scan.sh"]

# ENTRYPOINT ["/opt/Fortify/SCA/bin/sourceanalyzer"]
