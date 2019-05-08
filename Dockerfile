FROM nixos/nix

# TODO Remove Override New Helm Version, once updated in nix repos https://github.com/NixOS/nixpkgs/pull/56837
RUN nix-channel --update && nix-env -i awscli kubectl aws-iam-authenticator
RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz && tar xvf helm-v2.13.1-linux-amd64.tar.gz && mv linux-amd64/{helm,tiller} /usr/bin && rm -rf linux-amd64 && rm -f helm-v2.13.1-linux-amd64.tar.gz