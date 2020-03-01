source 'https://rubygems.org'

# application
gem 'sinatra', '~> 1.4.7'
gem 'slim', '~> 3.0.6'
gem 'redis', '~> 3.3.0'
gem 'rack', '~> 1.6'
gem 'thin', '~> 1.6.4'
gem 'sinatra-contrib', '~> 1.4.6'
gem 'sinatra-formhelpers-ng'

group :development do
  gem 'rubocop', '~> 0.48.1', require: false
  gem 'pry'
end

group :test, :development do
  gem 'capybara', '~> 2.6.2'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
  gem 'mock_redis'
  gem 'simplecov', :require => false
end
