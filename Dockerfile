FROM nixos/nix

RUN nix-channel --update && nix-env -i awscli kubectl helm aws-iam-authenticator

# TODO Remove Override New Helm Version, once updated in nix repos https://github.com/NixOS/nixpkgs/pull/56837
# RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz && tar xvf helm-v2.13.1-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin && mv linux-amd64/tiller /usr/bin && rm -rf linux-amd64 && rm -f helm-v2.13.1-linux-amd64.tar.gz