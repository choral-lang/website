#!/bin/sh

docker run -it --rm -v "$(pwd)"/web:/srv/jekyll	-v "$(pwd)"/.docker-cache:/usr/local/bundle jekyll/jekyll jekyll build
