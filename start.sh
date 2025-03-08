#!/usr/bin/env bash

/bin/ollama serve & /tired-proxy --origin=http://localhost:11434 --idle-time=90 --verbose=true