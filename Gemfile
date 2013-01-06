# -*- coding: utf-8; mode: ruby; -*-
source "http://rubygems.org"

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

group :development do
  gem 'growl', :require => darwin_only('growl')
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent', '~> 0.9.1', :require => darwin_only('rb-fsevent')
  gem 'rspec'
end

gem 'os'
