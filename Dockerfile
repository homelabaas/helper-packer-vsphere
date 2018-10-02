FROM hashicorp/packer:light

RUN apk add --update git curl openssh
WORKDIR /bin
RUN wget https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v2.0/packer-builder-vsphere-clone.linux --quiet && \
    chmod +x packer-builder-vsphere-clone.linux 
RUN wget https://github.com/jetbrains-infra/packer-builder-vsphere/releases/download/v2.0/packer-builder-vsphere-iso.linux --quiet && \
    chmod +x packer-builder-vsphere-iso.linux
RUN wget https://dl.minio.io/client/mc/release/linux-amd64/mc --quiet && \
    chmod +x mc

COPY ./packer-build.sh .
COPY ./sync-minio.sh .
RUN chmod +x packer-build.sh && chmod +x sync-minio.sh

ENTRYPOINT [ "/bin/packer-build.sh" ]