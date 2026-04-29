FROM node:25-alpine

RUN apk add --no-cache dumb-init

WORKDIR /work

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["dumb-init", "--", "entrypoint"]
