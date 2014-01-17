FROM jarosser06/ubuntu-ruby-2.0.0
MAINTAINER Jim Rosser, jarosser06@tamu.edu

ADD . /opt/dhcp-dash
WORKDIR /opt/dhcp-dash
RUN gem install bundler
RUN bundle install

EXPOSE 80
CMD ["unicorn", "-c" "unicorn.rb"]
