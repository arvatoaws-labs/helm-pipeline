FROM alekzonder/archlinux-yaourt

RUN sudo -u yaourt yaourt --noconfirm -Syyu

RUN sudo -u yaourt yaourt --noconfirm -S kubernetes-helm kubectl