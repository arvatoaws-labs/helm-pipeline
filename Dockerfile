FROM fedora

RUN dnf upgrade -y && dnf install -y awscli wget kubernetes-client && dnf clean all
RUN wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz && tar xf helm-v2.16.1-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && rm -rf linux-amd64 helm-v2.16.1-linux-amd64.tar.gz
