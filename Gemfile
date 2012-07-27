source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'gds-warmup-controller'

gem 'rails', '~> 3.2.6'
gem 'rails-i18n'
gem 'json'
gem 'plek', '~> 0.1'
gem 'rummageable'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification'
gem 'lograge'
if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '0.2.0'
end
gem 'htmlentities', '~> 4'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '1.1.45'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', '~> 0.8.15'
end

group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'ci_reporter'
  gem 'mocha', :require => false
  gem "shoulda", "~> 2.11.3"
  gem 'webmock', :require => false
  gem "simplecov", "0.4.2"
  gem 'capybara-webkit', "~> 0.12.1"
end

group :assets do
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end

if ENV['RUBY_DEBUG']
  gem 'ruby-debug19'
end

group :analytics do
  gem "google-api-client", :require => 'google/api_client'
end
