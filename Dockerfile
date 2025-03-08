FROM ollama/ollama:latest

COPY --from=tiesv/tired-proxy:latest /tired-proxy /tired-proxy
COPY /start.sh /

RUN chmod +x /start.sh

ENV OLLAMA_DEBUG="1"

EXPOSE 8080
ENTRYPOINT [ ]
CMD [ "/start.sh" ]