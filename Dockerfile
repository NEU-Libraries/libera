FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y \
  ghostscript \
  libgs-dev \
  imagemagick \
  tesseract-ocr
RUN rm -f /usr/local/lib/ruby/gems/2.5.0/specifications/default/fileutils-1.0.2.gemspec
RUN useradd -ms /bin/bash libera
USER libera
RUN mkdir -p /home/libera/source
WORKDIR /home/libera/source
COPY --chown=libera:libera . /home/libera/source
RUN /home/libera/source/bin/setup
RUN gem build libera.gemspec
RUN gem install libera-1.0.4.gem
