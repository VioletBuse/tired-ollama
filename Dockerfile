FROM node#23-alpine3.20 AS proxy_build

WORKDIR /workdir 

COPY . .
RUN npm ci
RUN npm run build

FROM ollama/ollama:latest AS main

COPY --from=tiesv/tired-proxy:latest /tired-proxy /tired-proxy
COPY --from=proxy_build /workdir/dist/tired-ollama-proxy-linux /
COPY /start.sh /

RUN chmod +x /start.sh

ENV OLLAMA_DEBUG="1"

EXPOSE 8080
ENTRYPOINT [ ]
CMD [ "/start.sh" ]