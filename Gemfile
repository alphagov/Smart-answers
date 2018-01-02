source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp

gem 'rails', '5.0.5'
gem "railties"
gem "sprockets-rails"

# Upgrade to Sentry
gem "govuk_app_config", "~> 0.2.0"

gem 'ast'
gem "gds-api-adapters", "~> 50.8.0"
gem 'govspeak', '~> 3.3.0'
gem 'govuk-content-schema-test-helpers', '~> 1.3.0'
gem 'govuk_frontend_toolkit', '>= 6.0.4'
gem 'htmlentities', '~> 4'
gem 'json'
gem 'logstasher', '1.2.2'
gem 'lrucache', '0.1.4'
gem 'method_source'
gem 'parser'
gem 'plek', '1.12.0'
gem 'rack_strip_client_ip'
gem 'rails-i18n'
gem 'sass-rails', '~> 5.0.7'
gem 'slimmer', '~> 11.1.1'
gem 'tilt', '2.0.8'
gem 'uglifier'
gem 'uk_postcode', '~> 1.0.1'
gem 'unicorn', '5.4.0'
gem 'rails_stdout_logging'
gem 'govuk_navigation_helpers', '~> 6.3.0'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'nokogiri'
end

group :development, :test do
  gem 'govuk-lint'
  gem 'pry'
  gem 'byebug'
end

group :test do
  gem 'rails-controller-testing'
  gem 'capybara', '2.16.1'
  gem 'ci_reporter'
  gem 'minitest', '~> 5.11'
  gem 'minitest-focus', '~> 1.1', '>= 1.1.2'
  gem 'mocha', '1.3.0', require: false
  gem 'poltergeist', '1.6.0'
  gem 'shoulda', '~> 3.5.0'
  gem 'simplecov', '~> 0.10.0', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
  gem 'timecop'
  gem 'webmock', '1.20.4', require: false
end
