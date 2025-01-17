ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=debian
ARG BASE_TAG=stable-slim

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} AS base

ENV FORTIFY_INSTALL_DIR=/opt/Fortify/SCA

RUN groupadd -g 10000 fortify && \
    useradd -M -s /usr/sbin/nologin --uid 10000 -g fortify fortify

WORKDIR /sca

COPY ./installer ./

ENV PATH=${PATH}:${FORTIFY_INSTALL_DIR}/bin

RUN chmod +x *.run && \
    mv *.run fortify_sca.run && \
    ./fortify_sca.run --mode unattended --InstallSamples 0 && \
    rm -f /sca/* && \
    /opt/Fortify/SCA/bin/fortifyupdate && \
    # Remove IDE plugins
    rm -rf /opt/Fortify/SCA/plugins && \
    # Remove tools for Apex and Visualforce Code
    rm -rf /opt/Fortify/SCA/Tools  && \
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

ADD --chown=fortify:fortify entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER fortify

WORKDIR /src

ENTRYPOINT ["/entrypoint.sh"]
