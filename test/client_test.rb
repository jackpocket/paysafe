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

  def test_credentials_predicate
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
    assert_equal 'The authentication credentials are invalid. (Code 5279)', error.message
  end

  def test_client_deprecations
    client = Paysafe::REST::Client.new

    [
      [ :customer_vault, :create_single_use_token, nil, {} ],
      [ :customer_vault, :create_profile_from_token, :create_profile, {} ],
      [ :customer_vault, :create_profile, nil, { merchant_customer_id: '', locale: '' } ],
      [ :customer_vault, :delete_profile, nil, { id: '' } ],
      [ :customer_vault, :get_profile, nil, { id: '' } ],
      [ :customer_vault, :update_profile, nil, { id: '', merchant_customer_id: '', locale: '' } ],
      [ :customer_vault, :create_address, nil, { profile_id: '', country: '', zip: '' } ],
      [ :customer_vault, :get_address, nil, { profile_id: '', id: '' } ],
      [ :customer_vault, :create_card_from_token, :create_card, { profile_id: '', token: '' } ],
      [ :customer_vault, :create_card, nil, { profile_id: '' } ],
      [ :customer_vault, :delete_card, nil, { profile_id: '', id: '' } ],
      [ :customer_vault, :get_card, nil, { profile_id: '', id: '' } ],
      [ :customer_vault, :update_card, nil, { profile_id: '', id: '', month: '', year: '' } ],
      [ :card_payments, :purchase, :create_authorization, { amount: '', token: '', merchant_ref_num: '' } ],
      [ :card_payments, :create_verification_from_token, :create_verification, { merchant_ref_num: '', token: '' } ]
    ].each do |api_name, method_name, new_method_name, arguments|
      new_method_name = new_method_name || method_name

      assert_called(client.send(api_name), new_method_name, times: 1) do
        _, stderror = capture_io do
          client.send(method_name, arguments)
        end

        assert_match "[DEPRECATION] '#{method_name}' is deprecated. Please use '#{api_name}.#{new_method_name}' instead", stderror
      end
    end
  end
end
