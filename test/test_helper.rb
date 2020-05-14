$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'paysafe'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/mock_expectations'
require 'webmock/minitest'
require 'vcr'
require 'dotenv/load'

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.default_cassette_options = { record: (ENV['RECORD_MODE'] || :once).to_sym }
  c.hook_into :webmock
  c.filter_sensitive_data('<ACCOUNT_NUMBER>') { ENV['PAYSAFE_ACCOUNT_NUMBER'] }
  c.filter_sensitive_data('<API_TOKEN>') do |interaction|
    Base64.strict_encode64("#{ENV['PAYSAFE_API_KEY']}:#{ENV['PAYSAFE_API_SECRET']}")
  end
  c.filter_sensitive_data('<SUT_TOKEN>') do |interaction|
    Base64.strict_encode64("#{ENV['PAYSAFE_SUT_API_KEY']}:#{ENV['PAYSAFE_SUT_API_SECRET']}")
  end
  c.filter_sensitive_data('<UNITY_TOKEN>') do |interaction|
    Base64.strict_encode64("#{ENV['PAYSAFE_UNITY_API_KEY']}:#{ENV['PAYSAFE_UNITY_API_SECRET']}")
  end
end

UUID_REGEX = /([a-f0-9\-]+)/
TOKEN_REGEX = /([a-zA-Z0-9]+)/
IP_ADDRESS_REGEX = /([0-9\.]+)/
AUTH_CODE_REGEX = /\d+/
NUMBER_REGEX = /\d+\.?\d*/

def authenticated_client
  Paysafe::REST::Client.new(
    account_number: ENV['PAYSAFE_ACCOUNT_NUMBER'],
    api_key: ENV['PAYSAFE_API_KEY'],
    api_secret: ENV['PAYSAFE_API_SECRET']
  )
end

def sut_client
  Paysafe::REST::Client.new(
    api_key: ENV['PAYSAFE_SUT_API_KEY'],
    api_secret: ENV['PAYSAFE_SUT_API_SECRET']
  )
end

def unity_client
  Paysafe::REST::Client.new(
    api_key: ENV['PAYSAFE_UNITY_API_KEY'],
    api_secret: ENV['PAYSAFE_UNITY_API_SECRET']
  )
end

def create_test_profile(**data)
  authenticated_client.customer_vault.create_profile(
    merchant_customer_id: random_id,
    locale: 'en_US',
    first_name: 'test',
    last_name: 'test',
    email: 'test@test.com',
    **data
  )
end

def create_test_profile_with_card_and_address
  create_test_profile(
    card: {
      card_num: '4111111111111111',
      card_expiry: {
        month: 12,
        year: 2050
      },
      billing_address: {
        country: 'US',
        zip: '10014'
      }
    }
  )
end

def create_test_customer(**data)
  unity_client.payments.create_customer(
    merchant_customer_id: random_id,
    **data
  )
end

def random_id
  SecureRandom.uuid
end
