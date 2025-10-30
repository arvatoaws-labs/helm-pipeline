FROM ghcr.io/arvatoaws-labs/fedora:43

VOLUME /var/lib/docker

ADD det-arch.sh /usr/local/bin

# base
RUN dnf upgrade -y && dnf install -y sed wget curl kubernetes1.34-client git openssh-clients jq bc findutils unzip golang gawk openssl procps-ng which file
ENV PATH="/root/go/bin:$PATH"

# github
ADD gh-scripts/* /usr/local/bin/

# custom
ADD custom-scripts/* /usr/local/bin/

ARG BUILDX_VERSION=0.29.1
COPY --from=docker /usr/local/bin/docker /usr/bin/
RUN mkdir -p /usr/local/lib/docker/cli-plugins && \
  curl -fsSL https://github.com/docker/buildx/releases/download/v$BUILDX_VERSION/buildx-v$BUILDX_VERSION.linux-`det-arch.sh a r` > /usr/local/lib/docker/cli-plugins/docker-buildx && \
  chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx && \
  docker buildx version

RUN go install github.com/git-chglog/git-chglog/cmd/git-chglog@latest

RUN dnf install -y dnf5-plugins && dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo && dnf install -y gh --repo gh-cli

RUN groupadd sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -G sudo -ms /bin/bash debug
USER debug
WORKDIR /home/debug
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
USER root
WORKDIR /root

RUN echo >> /root/.bashrc
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc

USER debug
WORKDIR /home/debug
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install hub kustomize awscli eksctl helm popeye yq fluxcd/tap/flux
USER root
WORKDIR /root

RUN dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_`det-arch.sh z r`/session-manager-plugin.rpm

RUN ln -s /home/linuxbrew/.linuxbrew/bin/helm /usr/bin/helm
RUN ln -s /home/linuxbrew/.linuxbrew/bin/helm /usr/bin/helm3
RUN helm3 plugin install https://github.com/helm/helm-mapkubeapis
RUN helm3 plugin install https://github.com/databus23/helm-diff
ADD helm-scripts/* /usr/local/bin/
RUN rm -rf ~/.ssh/known_hosts && \
  mkdir -p ~/.ssh && \
  ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN ln -s /home/linuxbrew/.linuxbrew/bin/aws /usr/bin/aws
RUN ln -s /home/linuxbrew/.linuxbrew/bin/yq /usr/bin/yq
RUN ln -s /home/linuxbrew/.linuxbrew/bin/popeye /usr/bin/popeye
RUN ln -s /home/linuxbrew/.linuxbrew/bin/flux /usr/bin/flux
RUN ln -s /home/linuxbrew/.linuxbrew/bin/kustomize /usr/bin/kustomize
RUN ln -s /home/linuxbrew/.linuxbrew/bin/eksctl /usr/bin/eksctl
RUN ln -s /home/linuxbrew/.linuxbrew/bin/hub /usr/bin/hub