From ubuntu:xenial
RUN apt-get update
RUN apt-get install -y git
RUN mkdir /src
COPY . /src/tmputils
RUN cd /src/tmputils/ && cp bin/setup_repo.sh /usr/local/bin && bash dev-image.sh /src
RUN rm -rf /src/tmputils
VOLUME /src

