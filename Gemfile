
# Herokup prefers 2.2.4, which was set with "heroku config:set CUSTOM_RUBY_VERSION=2.2.4"
ruby ENV['CUSTOM_RUBY_VERSION'] || '2.6.6'


source 'https://rubygems.org'

gem 'nokogiri'
gem 'twitter', :git => 'https://github.com/sferik/twitter.git', :branch => 'streaming-updates'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.10'
# Use postgres on Heroku
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Heroku wants me to add this. ::shrug::
gem 'rails_12factor', '~> 0.0.3'
