FROM golang:1.19-alpine as builder
ENV CGO_ENABLED=0

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache --update ca-certificates make git && \
    rm -rf /var/cache/apk* 
ENV version=6
WORKDIR /src/
COPY signal/main.go signal/go.* /src/
RUN CGO_ENABLED=0 go build -o /bin/signal


FROM ubuntu:22.04 as tanzu
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update -y \
  && apt-get install -y \
       wget \
       git 
ENV version=6
COPY --from=builder /bin/signal /signal
RUN wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O - | bash -
WORKDIR  /tmp/
RUN wget -O /tmp/tanzu-cli-bundle-linux-amd64.tar.gz https://download3.vmware.com/software/TKG-160/tanzu-cli-bundle-linux-amd64.tar.gz
RUN tar zxvf /tmp/tanzu-cli-bundle-linux-amd64.tar.gz 
RUN rm /tmp/tanzu-cli-bundle-linux-amd64.tar.gz
RUN install /tmp/cli/core/v0.25.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu


FROM ubuntu:22.04
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y \
     wget \
     curl \
     git \
     jq \
  && apt-get clean autoclean && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && /usr/bin/curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl  \
  && mv ./kubectl /bin/kubectl
ENV version=6
COPY --from=builder /bin/signal /signal
COPY --from=tanzu /usr/local/bin/tanzu /usr/local/bin/tanzu
RUN wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O - | bash -
STOPSIGNAL SIGQUIT
ENTRYPOINT ["./signal"]
