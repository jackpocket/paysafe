$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'paysafe'
require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'
require 'vcr'
require 'dotenv/load'

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

RECORD_MODE = (ENV['RECORD_MODE'] || 'once').to_sym
VCR_CASSETTE_DIR = "test/cassettes"

if RECORD_MODE == :all
  require "fileutils"
  FileUtils.rm_rf VCR_CASSETTE_DIR
end

VCR.configure do |c|
  c.cassette_library_dir = VCR_CASSETTE_DIR
  c.hook_into :webmock
  c.filter_sensitive_data('<ACCOUNT_NUMBER>') { ENV['PAYSAFE_ACCOUNT_NUMBER'] }
  c.filter_sensitive_data('<API_TOKEN>') do |interaction|
    Base64.strict_encode64("#{ENV['PAYSAFE_API_KEY']}:#{ENV['PAYSAFE_API_SECRET']}")
  end
  c.filter_sensitive_data('<SUT_TOKEN>') do |interaction|
    Base64.strict_encode64("#{ENV['PAYSAFE_SUT_API_KEY']}:#{ENV['PAYSAFE_SUT_API_SECRET']}")
  end
end

UUID_REGEX = /([a-f0-9\-]+)/
TOKEN_REGEX = /([a-zA-Z0-9]+)/

def authenticated_client
  Paysafe::REST::Client.new(
    account_number: ENV['PAYSAFE_ACCOUNT_NUMBER'] || '1234567890',
    api_key: ENV['PAYSAFE_API_KEY'] || 'api_key',
    api_secret: ENV['PAYSAFE_API_SECRET'] || 'api_secret'
  )
end

def authenticated_sut_client
  Paysafe::REST::Client.new(
    api_key: ENV['PAYSAFE_SUT_API_KEY'],
    api_secret: ENV['PAYSAFE_SUT_API_SECRET']
  )
end

def create_empty_profile
  authenticated_client.customer_vault.create_profile(
    merchant_customer_id: random_id,
    locale: 'en_US'
  )
end

def random_id
  SecureRandom.uuid
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
