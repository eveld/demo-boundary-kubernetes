FROM ubuntu:latest

RUN apt update && apt install -y openssh-server supervisor

RUN mkdir /run/sshd

CMD ["/usr/bin/supervisord"]
