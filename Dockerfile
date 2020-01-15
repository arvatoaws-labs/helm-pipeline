FROM fedora

RUN dnf upgrade -y && dnf install -y awscli wget kubernetes-client git hub openssh-clients jq && dnf clean all
RUN wget https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz && tar xf helm-v2.16.1-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && rm -rf linux-amd64 helm-v2.16.1-linux-amd64.tar.gz && ln -s /usr/bin/helm /usr/bin/helm2
RUN wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz && tar xf helm-v3.0.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/helm3 && rm -rf linux-amd64 helm-v3.0.2-linux-amd64.tar.gz
ADD migrate-helm.sh /usr/local/bin/migrate-helm.sh
ADD create-ns.sh /usr/local/bin/create-ns.sh
RUN rm -rf ~/.ssh/known_hosts && mkdir ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
RUN helm init --client-only && helm plugin install https://github.com/helm/helm-2to3
