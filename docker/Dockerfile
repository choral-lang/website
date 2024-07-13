FROM ruby as Build
COPY web /srv/jekyll
WORKDIR /srv/jekyll
RUN bundle install
RUN bundle exec jekyll build
RUN mv /srv/jekyll/_site /site

FROM jolielang/leonardo:edge
ENV LEONARDO_WWW /web
COPY --from=Build /site $LEONARDO_WWW
