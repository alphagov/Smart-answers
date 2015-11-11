source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '4.2.4'

gem 'airbrake', '~> 3.1.17'
gem 'extlib', '0.9.16'
gem 'govuk-content-schema-test-helpers', '~> 1.3.0'
gem 'govuk_frontend_toolkit', '3.1.0'
gem 'htmlentities', '~> 4'
gem 'json'
gem 'logstasher', '0.4.8'
gem 'lrucache', '0.1.4'
gem 'plek', '1.7.0'
gem 'rack_strip_client_ip', '0.0.1'
gem 'rails-i18n'
gem 'sass-rails', '~> 4.0.0'
gem 'tilt', '1.4.1'
gem 'therubyracer', '~> 0.12.1'
gem 'uglifier'
gem 'uk_postcode', '~> 1.0.1'
gem 'unicorn', '4.8.3'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'govuk-lint'
  gem 'nokogiri'
end

group :development, :test do
  gem 'pry'
end

group :test do
  gem 'capybara', '2.1.0'
  gem 'ci_reporter'
  gem 'minitest', '~> 5.1'
  gem 'mocha', '1.1.0', require: false
  gem 'poltergeist', '1.6.0'
  gem 'shoulda', '~> 3.5.0'
  gem 'simplecov', '~> 0.10.0', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
  gem 'timecop'
  gem 'webmock', '1.20.4', require: false
end

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 25.1'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 3.3.0'
end

if ENV['RUBY_DEBUG']
  gem 'debugger', require: "ruby-debug"
end

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '9.0.0'
end
