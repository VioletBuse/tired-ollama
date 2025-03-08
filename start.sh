#!/usr/bin/env bash

/bin/ollama serve & /tired-ollama-proxy-linux serve --origin=http://localhost:11434 --idle-time=25