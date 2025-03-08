#!/usr/bin/env sh

rm -rf ./tired-ollama-proxy.blob
rm -rf ./tired-ollama-proxy

node --experimental-sea-config executable-config.json
cp $(command -v node) tired-ollama-proxy

OS="$(uname)"

if [ "$OS" = "Linux" ]; then
    echo "Running on Linux"

    sudo npx postject tired-ollama-proxy TIRED_OLLAMA_PROXY tired-ollama-proxy.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
elif [ "$OS" = "Darwin" ]; then
    echo "Running on macOS"

    codesign --remove-signature ./tired-ollama-proxy

    sudo npx postject tired-ollama-proxy TIRED_OLLAMA_PROXY tired-ollama-proxy.blob \
        --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
        --macho-segment-name NODE_SEA

    codesign --sign - ./tired-ollama-proxy
else
    echo "Unsupported OS: $OS"
fi

rm -rf ./tired-ollama-proxy.blob