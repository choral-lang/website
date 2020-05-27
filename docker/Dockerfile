FROM ruby as Build
WORKDIR /srv/jekyll
RUN bundle install
COPY web /srv/jekyll
RUN bundle exec jekyll build
RUN mv /srv/jekyll/_site /site

FROM jolielang/leonardo
ENV LEONARDO_WWW /web
COPY --from=Build /site $LEONARDO_WWW
