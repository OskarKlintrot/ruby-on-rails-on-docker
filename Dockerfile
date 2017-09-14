FROM ruby:2.2 
MAINTAINER Certaincy

# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -  
RUN apt-get update && apt-get install -y \
  build-essential \
  locales \
  nodejs

# Use sv-SE.UTF-8 as our locale
RUN locale-gen sv_SE.UTF-8 
ENV LANG sv-SE.UTF-8 
ENV LANGUAGE sv-SE:en 
ENV LC_ALL sv-SE.UTF-8

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY src/Gemfile src/Gemfile.lock /app/
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Expose port 3000 to the Docker host, so we can access it 
# from the outside.
EXPOSE 3000

# Configure an entry point, so we don't need to specify 
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
CMD ["rails", "server", "-b", "0.0.0.0"]