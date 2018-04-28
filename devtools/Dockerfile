From ubuntu:xenial
SHELL ["bash", "-c"]
RUN apt-get update
RUN apt-get install -y git
RUN mkdir -p /src/tmputils
COPY general /src/tmputils/general
COPY bin /src/tmputils/bin
COPY conf.d /src/tmputils/conf.d
COPY dev-image.sh env.sh functions  /src/tmputils/
RUN apt-get install -y sudo
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
RUN locale
RUN cd /src/tmputils/ && ls && cp bin/*.sh /usr/local/bin && bash dev-image.sh /src
RUN rm -rf /src/tmputils
VOLUME /src
WORKDIR /src/go/src/github.com
