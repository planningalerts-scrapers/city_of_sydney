# frozen_string_literal: true

# It's easy to add more libraries or choose different versions. Any libraries
# specified here will be installed and made available to your morph.io scraper.
# Find out more: https://morph.io/documentation/ruby

source "https://rubygems.org"

ruby "3.2.2" # ruby 3.2.3 does NOT run on heroku-18!

gem "mechanize", "~> 2.14"
gem "nokogiri", "~> 1.17.2" # nokogiri 1.18 does NOT run on heroku-18!
gem "scraperwiki", git: "https://github.com/openaustralia/scraperwiki-ruby.git", branch: "morph_defaults"
gem "sqlite3", "~> 2.2.0" # sqlite3 2.3.0 does NOT run on heroku-18!
