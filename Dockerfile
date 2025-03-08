FROM node#23-alpine3.20 AS proxy_build

WORKDIR /workdir 

COPY . .
RUN npm ci
RUN chmod +x build.sh
RUN build.sh

FROM ollama/ollama:latest AS main

COPY --from=tiesv/tired-proxy:latest /tired-proxy /tired-proxy
COPY --from=proxy_build /workdir/tired-ollama-proxy /
COPY /start.sh /

RUN chmod +x /start.sh

ENV OLLAMA_DEBUG="1"

EXPOSE 8080
ENTRYPOINT [ ]
CMD [ "/start.sh" ]