#!/usr/bin/env bash
docker compose down 
rm -rf .jekyll-cache/ _site/
rsync -av --progress . /mnt/c/Users/Danijel.Wynyard/OneDrive\ -\ MRI\ Software/mri-docs/ --exclude .git --exclude _site --exclude .jekyll-cache
docker compose up -d