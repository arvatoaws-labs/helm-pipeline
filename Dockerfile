FROM ghcr.io/arvatoaws-labs/fedora:36

VOLUME /var/lib/docker

RUN dnf install -y sed

ADD det-arch.sh /usr/local/bin
ADD kubernetes.repo /etc/yum.repos.d/
RUN sed -i "s/x86_64/`det-arch.sh x c`/" /etc/yum.repos.d/kubernetes.repo

# base
RUN dnf upgrade -y && dnf install -y wget curl kubectl git hub openssh-clients jq bc findutils unzip

ARG GH_CLI_VERSION=2.21.1
RUN dnf install -y https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_`det-arch.sh a r`.rpm

# github
ADD gh-scripts/* /usr/local/bin/

# eksctl & fluxctl & others
ADD eksctl-scripts/* /usr/local/bin/

# custom
ADD custom-scripts/* /usr/local/bin/

ARG FLUXCTL_VERSION=1.24.3
RUN wget https://github.com/fluxcd/flux/releases/download/$FLUXCTL_VERSION/fluxctl_linux_`det-arch.sh a r` && mv fluxctl_linux_`det-arch.sh a r` /usr/bin/fluxctl && chmod +x /usr/bin/fluxctl

ARG YQ_VERSION=4.25.1
RUN wget https://github.com/mikefarah/yq/releases/download/v$YQ_VERSION/yq_linux_`det-arch.sh a r` && chmod +x yq_linux_`det-arch.sh a r` && mv yq_linux_`det-arch.sh a r` /usr/bin/yq

ARG VELERO_VERSION=1.9.0
RUN wget https://github.com/vmware-tanzu/velero/releases/download/v$VELERO_VERSION/velero-v$VELERO_VERSION-linux-`det-arch.sh a r`.tar.gz && tar xf velero-v$VELERO_VERSION-linux-`det-arch.sh a r`.tar.gz && mv velero-v$VELERO_VERSION-linux-`det-arch.sh a r`/velero /usr/bin/velero && rm -rf velero-v$VELERO_VERSION-linux-`det-arch.sh a r`.tar.gz velero-v$VELERO_VERSION-linux-`det-arch.sh a r`

ARG BUILDX_VERSION=0.7.0
COPY --from=docker /usr/local/bin/docker /usr/bin/
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
  curl -fsSL https://github.com/docker/buildx/releases/download/v$BUILDX_VERSION/buildx-v$BUILDX_VERSION.linux-`det-arch.sh a r` > /usr/local/lib/docker/cli-plugins/docker-buildx && \
  chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx && \
  docker buildx version

# Packer
ARG PACKER_VERSION=1.8.0
RUN wget https://releases.hashicorp.com/packer/$PACKER_VERSION/packer_${PACKER_VERSION}_linux_`det-arch.sh a r`.zip && unzip packer_${PACKER_VERSION}_linux_`det-arch.sh a r`.zip && mv packer /usr/bin && rm packer_${PACKER_VERSION}_linux_`det-arch.sh a r`.zip

ARG POPEYE_VERSION=0.10.0
RUN wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_Linux_`det-arch.sh x r`.tar.gz && tar xf popeye_Linux_`det-arch.sh x r`.tar.gz && mv popeye /usr/bin/ && rm -rf popeye_Linux_`det-arch.sh x r`.tar.gz

ARG HELM_3_VERSION=3.9.0
RUN wget https://get.helm.sh/helm-v${HELM_3_VERSION}-linux-`det-arch.sh a r`.tar.gz && \
tar xf helm-v${HELM_3_VERSION}-linux-`det-arch.sh a r`.tar.gz && \
mv linux-`det-arch.sh a r`/helm /usr/bin/helm3 && \
rm -rf linux-`det-arch.sh a r` helm-v${HELM_3_VERSION}-linux-`det-arch.sh a r`.tar.gz
ADD helm-scripts/* /usr/local/bin/
RUN rm -rf ~/.ssh/known_hosts && \
mkdir ~/.ssh && \
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

ARG FLUX_VERSION=0.31.1
RUN wget https://github.com/fluxcd/flux2/releases/download/v$FLUX_VERSION/flux_${FLUX_VERSION}_linux_`det-arch.sh a r`.tar.gz && tar xf flux_${FLUX_VERSION}_linux_`det-arch.sh a r`.tar.gz && mv flux /usr/bin && rm -f flux_${FLUX_VERSION}_linux_`det-arch.sh a r`.tar.gz

ARG EKSCTL_VERSION=0.102.0
RUN wget https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_`det-arch.sh a r`.tar.gz && tar xf eksctl_Linux_`det-arch.sh a r`.tar.gz && mv eksctl /usr/bin/ && rm -rf eksctl_Linux_`det-arch.sh a r`.tar.gz

# Session Manager
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-`det-arch.sh x c`.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install --bin-dir /usr/bin && rm -rf awscliv2.zip aws

RUN dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_`det-arch.sh z r`/session-manager-plugin.rpm
