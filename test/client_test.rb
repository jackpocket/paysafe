require 'test_helper'

class ClientTest < Minitest::Test

  def test_client_is_configured_with_defaults
    client = Paysafe::REST::Client.new

    assert_equal client.test_mode, true
    assert_nil client.timeouts
  end

  def test_client_is_configured_through_options
    client = Paysafe::REST::Client.new(
      account_number: 'account_number',
      api_key: 'api_key',
      api_secret: 'api_secret',
      test_mode: false,
      timeouts: { connect: 30 }
    )

    assert_equal client.account_number, 'account_number'
    assert_equal client.api_key, 'api_key'
    assert_equal client.api_secret, 'api_secret'
    assert_equal client.test_mode, false
    assert_equal client.timeouts, { connect: 30 }
  end

  def test_api_base_changes_based_on_test_mode
    client = Paysafe::REST::Client.new(test_mode: true)

    assert_equal client.test_mode, true
    assert_equal client.api_base, Paysafe::Configuration::API_TEST

    client = Paysafe::REST::Client.new(test_mode: false)

    assert_equal client.test_mode, false
    assert_equal client.api_base, Paysafe::Configuration::API_LIVE
  end

  def test_credentials_hash
    client = Paysafe::REST::Client.new(api_key: 'api_key', api_secret: 'api_secret')

    assert_equal client.credentials, { api_key: 'api_key', api_secret: 'api_secret' }
  end

  def test_credentials?
    client = Paysafe::REST::Client.new(api_key: 'api_key', api_secret: 'api_secret')
    assert client.credentials?

    client = Paysafe::REST::Client.new(api_key: 'api_key')
    refute client.credentials?

    client = Paysafe::REST::Client.new(api_secret: 'api_secret')
    refute client.credentials?
  end

  def test_client_unauthorized_error
    error = assert_raises(Paysafe::Error::Unauthorized) do
      VCR.use_cassette('client_unauthorized_error') do
        client = Paysafe::REST::Client.new
        client.customer_vault.get_profile(id: 'id')
      end
    end

    assert_equal '5279', error.code
    assert_equal 'The authentication credentials are invalid.', error.message
  end

end
