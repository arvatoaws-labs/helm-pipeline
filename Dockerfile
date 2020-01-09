FROM fedora

RUN dnf upgrade -y && dnf install -y awscli wget kubernetes-client git hub openssh-clients jq && dnf clean all
RUN rm -rf ~/.ssh/known_hosts && mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
RUN wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz && tar xf helm-v2.16.1-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && rm -rf linux-amd64 helm-v2.16.1-linux-amd64.tar.gz
RUN wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz && tar xf helm-v3.0.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/helm3 && rm -rf linux-amd64 helm-v3.0.2-linux-amd64.tar.gz
