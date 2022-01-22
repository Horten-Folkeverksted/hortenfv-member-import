FROM alpine:latest

RUN apk add curl jq postgresql-client
RUN mkdir -p /app
RUN mkdir -p /data
COPY app.sh /app/

WORKDIR /
CMD /app/app.sh
