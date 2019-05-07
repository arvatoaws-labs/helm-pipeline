FROM nixos/nix

RUN nix-channel --update && nix-env -i awscli helm kubectl aws-iam-authenticator