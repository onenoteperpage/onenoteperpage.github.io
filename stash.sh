#!/usr/bin/env bash
date=$(date '+%Y-%m-%d')
docker compose down 
rm -rf .jekyll-cache/ _site/
git add .
git commit -m  "$date"
rsync -av --progress . /mnt/c/Users/Danijel.Wynyard/OneDrive\ -\ MRI\ Software/mri-docs/ --exclude .git --exclude _site --exclude .jekyll-cache
git push
