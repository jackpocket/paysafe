$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'paysafe'
require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'
require 'vcr'
require 'dotenv'

Dotenv.load

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
end

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

def test_client
  Paysafe::REST::Client.new do |config|
    config.account_number = '1234567890'
    config.api_key = 'api_key'
    config.api_secret = 'api_secret'
  end
end

def authenticated_client
  Paysafe::REST::Client.new do |config|
    config.account_number = ENV['PAYSAFE_ACCOUNT_NUMBER'] || '1234567890'
    config.api_key = ENV['PAYSAFE_API_KEY'] || 'api_key'
    config.api_secret = ENV['PAYSAFE_API_SECRET'] || 'api_secret'
  end
end

def turn_on_vcr!
  VCR.turn_on!
  WebMock.disable_net_connect!
end

def turn_off_vcr!
  WebMock.allow_net_connect!
  VCR.turn_off!
end

#   def assert_json(expected, message=nil)
#     @json ||= JSON.parse(response.body)
#
#     if expected.is_a?(Array)
#       expected.map! &:deep_stringify_keys!
#     else
#       expected.deep_stringify_keys!
#     end
#
#     assert_equal @json, expected, message
#   end
