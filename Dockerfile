FROM alpine:latest

RUN apk add --no-cache bash

WORKDIR /app

COPY matchstick.sh .

RUN chmod +x matchstick.sh

ENTRYPOINT ["bash", "./matchstick.sh"]
