FROM ubuntu:zesty AS build

ARG repository=https://github.com/coinonat/CoinonatX.git
ARG branch=master

WORKDIR /tmp
RUN apt-get update -qq
RUN apt-get install -qq -y --no-install-recommends ca-certificates git build-essential libboost-all-dev libssl-dev libdb-dev libdb++-dev
RUN git clone -b ${branch} ${repository} .
ADD build.patch .
RUN patch -p1 -i build.patch

WORKDIR /tmp/src
RUN make -f makefile.unix STATIC=1
RUN strip coinonatxd


FROM ubuntu:zesty AS publish
COPY --from=build /tmp/src/coinonatxd /usr/local/bin
RUN ln -s /srv /root/.CoinonatX

EXPOSE 44678 44578
VOLUME ["/srv"]
ENTRYPOINT ["/usr/local/bin/coinonatxd", "-printtoconsole", "-pid=/run/coinonatxd.pid", "-datadir=/srv", "-daemon=0"]
CMD ["-server=0"]
