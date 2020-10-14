FROM fedora:32

ADD test /
RUN dnf install -y sed
RUN sed -i "s/x86_64/`uname -m`/" /test
