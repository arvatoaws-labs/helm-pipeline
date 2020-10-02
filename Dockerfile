FROM mikefarah/yq AS yq
FROM fedora

ARG HELM_2_VERSION=2.16.12
ARG HELM_3_VERSION=3.3.4
ARG GH_CLI_VERSION=1.0.0
ARG EKSCTL_VERSION=0.29.0
ARG POPEYE_VERSION=0.8.10
ARG FLUXCTL_VERSION=1.21.0
ARG VELERO_VERSION=1.5.1

COPY --from=yq /usr/bin/yq /usr/bin/
ADD kubernetes.repo /etc/yum.repos.d/

# base
RUN dnf upgrade -y && dnf install -y awscli wget curl kubectl git sed hub openssh-clients jq bc && dnf clean all

# helm
RUN wget https://get.helm.sh/helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && \
tar xf helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && \
rm -rf linux-amd64 helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && \
ln -s /usr/bin/helm /usr/bin/helm2 && \
wget https://get.helm.sh/helm-v${HELM_3_VERSION}-linux-amd64.tar.gz && \
tar xf helm-v${HELM_3_VERSION}-linux-amd64.tar.gz && \
mv linux-amd64/helm /usr/bin/helm3 && \
rm -rf linux-amd64 helm-v${HELM_3_VERSION}-linux-amd64.tar.gz
ADD helm-scripts/* /usr/local/bin/
RUN rm -rf ~/.ssh/known_hosts && \
mkdir ~/.ssh && \
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
helm init --client-only && \
helm plugin install https://github.com/helm/helm-2to3

# github
ADD gh-scripts/* /usr/local/bin/
RUN dnf install -y https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_linux_amd64.rpm

# eksctl & fluxctl & others
ADD eksctl-scripts/* /usr/local/bin/
RUN wget https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz && tar xf eksctl_Linux_amd64.tar.gz && mv eksctl /usr/bin/ && rm -rf eksctl_Linux_amd64.tar.gz && \
wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_Linux_x86_64.tar.gz && tar xf popeye_Linux_x86_64.tar.gz && mv popeye /usr/bin/ && rm -rf popeye_Linux_x86_64.tar.gz && \
wget https://github.com/fluxcd/flux/releases/download/$FLUXCTL_VERSION/fluxctl_linux_amd64 && mv fluxctl_linux_amd64 /usr/bin/fluxctl && chmod +x /usr/bin/fluxctl

RUN wget https://github.com/vmware-tanzu/velero/releases/download/v$VELERO_VERSION/velero-v$VELERO_VERSION-linux-amd64.tar.gz && tar xf velero-v$VELERO_VERSION-linux-amd64.tar.gz && mv velero-v$VELERO_VERSION-linux-amd64/velero /usr/bin/velero && rm -rf velero-v$VELERO_VERSION-linux-amd64.tar.gz velero-v$VELERO_VERSION-linux-amd64