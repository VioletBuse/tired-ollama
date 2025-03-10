FROM node:20-alpine AS proxy_build

WORKDIR /workdir 

COPY . .
RUN npm ci
RUN npm run build

FROM ollama/ollama:latest AS main

RUN apt-get -y update && apt-get -y install ca-certificates curl e2fsprogs && apt-get -y clean && rm -rf /var/lib/apt/lists/*
RUN curl -sSL https://d.juicefs.com/install | sh -

COPY --from=tiesv/tired-proxy:latest /tired-proxy /tired-proxy
COPY --from=proxy_build /workdir/dist/tired-ollama-proxy-linux /
COPY /start.sh /

RUN chmod +x /start.sh

EXPOSE 8080
ENTRYPOINT [ ]
CMD [ "/start.sh" ]