FROM alekzonder/archlinux-yaourt

RUN sudo -u yaourt yaourt --noconfirm -Syyu

RUN sudo -u yaourt yaourt --noconfirm -S kubernetes-helm kubectl aws-cli aws-iam-authenticator-bin && yes | sudo -u yaourt yaourt -Qtd
