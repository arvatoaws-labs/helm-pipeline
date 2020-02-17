FROM fedora

ARG HELM_2_VERSION=2.16.3
ARG HELM_3_VERSION=3.1.0

RUN dnf upgrade -y && dnf install -y awscli wget kubernetes-client git hub openssh-clients jq && dnf clean all
RUN wget https://get.helm.sh/helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && tar xf helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && rm -rf linux-amd64 helm-v${HELM_2_VERSION}-linux-amd64.tar.gz && ln -s /usr/bin/helm /usr/bin/helm2
RUN wget https://get.helm.sh/helm-v${HELM_3_VERSION}-linux-amd64.tar.gz && tar xf helm-v${HELM_3_VERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/helm3 && rm -rf linux-amd64 helm-v${HELM_3_VERSION}-linux-amd64.tar.gz
ADD migrate-helm.sh /usr/local/bin/migrate-helm.sh
ADD create-ns.sh /usr/local/bin/create-ns.sh
RUN rm -rf ~/.ssh/known_hosts && mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
RUN helm init --client-only && helm plugin install https://github.com/helm/helm-2to3
