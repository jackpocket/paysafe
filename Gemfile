source "https://rubygems.org"

gem "rake"
gem "base64"
gem "dotenv"
gem "minitest", "~> 6.0"
gem "minitest-reporters"
gem "vcr"
gem "webmock"
gem "cgi" # needed for Ruby 4.0 until http-cookie gem adds dependency

group :test do
  gem "simplecov", require: false
  gem "simplecov-cobertura"
end

# Specify your gem's dependencies in paysafe.gemspec
gemspec
