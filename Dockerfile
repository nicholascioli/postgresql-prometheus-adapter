# Inspired by https://github.com/CrunchyData/postgresql-prometheus-adapter/pull/21

# First build the code statically
FROM docker.io/library/golang:alpine AS build

WORKDIR /source
COPY . /source

RUN go get
RUN GOOS=linux go build \
    -ldflags="-X 'main.Version=${VERSION}' -extldflags '-static'" \
    -o /postgresql-prometheus-adapter \
    -v \
    .

# Create minimal /etc/passwd for dropping privileges
RUN echo "appuser:x:10001:10001:App User:/:/sbin/nologin" > /etc/minimal-passwd


# Now build the actual container with just the generated binary
FROM scratch

COPY --from=build /postgresql-prometheus-adapter /postgresql-prometheus-adapter
COPY --from=build /etc/minimal-passwd /etc/passwd

USER appuser
MAINTAINER Yogesh Sharma <Yogesh.Sharma@CrunchyData.com>
ENTRYPOINT ["/postgresql-prometheus-adapter"]
