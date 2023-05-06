FROM ruby:3.1.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /plmhealthone-app
COPY Gemfile /plmhealthone-app/Gemfile
COPY Gemfile.lock /plmhealthone-app/Gemfile.lock
RUN bundle install
COPY . /plmhealthone-app


COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]