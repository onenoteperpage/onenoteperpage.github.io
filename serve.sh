#!/usr/bin/env bash
docker compose down 
rm -rf .jekyll-cache/ _site/
docker compose up