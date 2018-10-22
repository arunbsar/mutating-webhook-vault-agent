FROM golang:1.11 AS builder

WORKDIR $GOPATH/src/github.com/openlab-red/mutating-webhook-vault-agent/

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