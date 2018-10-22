FROM golang:1.11 AS builder

ADD https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 /usr/bin/dep
RUN chmod +x /usr/bin/dep

WORKDIR $GOPATH/src/github.com/openlab-red/mutating-webhook-vault-agent

COPY Gopkg.toml Gopkg.lock ./

RUN dep ensure --vendor-only

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /app .

FROM fedora:28

ENV HOME=/home/mutating-webhook-vault-agent
RUN mkdir -p $HOME

COPY --from=builder /app $HOME

RUN chown -R 1001:0 $HOME && \
    chmod -R g+rw $HOME

WORKDIR $HOME

USER 1001

ENTRYPOINT ["./app"]