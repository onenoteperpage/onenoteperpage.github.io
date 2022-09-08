$JEKYLL_VERSION="3.8"
docker stop jekyll-blog
docker run --rm --volume="${pwd}:/srv/jekyll:z" -it jekyll/jekyll:$JEKYLL_VERSION jekyll build
docker run -d --name jekyll-blog --rm --volume="${pwd}:/srv/jekyll:z" -p 4000:4000 -it jekyll/jekyll:$JEKYLL_VERSION jekyll serve