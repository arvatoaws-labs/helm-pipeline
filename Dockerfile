FROM nixos/nix

RUN nix-channel --update && nix-env -i awscli kubectl helm aws-iam-authenticator