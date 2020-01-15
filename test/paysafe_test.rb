require 'test_helper'

class PaysafeTest < Minitest::Test

  def setup
    turn_on_vcr!
  end

  def teardown
    turn_off_vcr!
  end

  def test_that_it_has_a_version_number
    refute_nil ::Paysafe::VERSION
  end

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
    assert_equal client.api_base, 'https://api.test.paysafe.com'

    client = Paysafe::REST::Client.new(test_mode: false)

    assert_equal client.test_mode, false
    assert_equal client.api_base, 'https://api.paysafe.com'
  end

  def test_credentials?
    client = Paysafe::REST::Client.new(api_key: 'api_key', api_secret: 'api_secret')
    assert client.credentials?

    client = Paysafe::REST::Client.new(api_key: 'api_key')
    refute client.credentials?

    client = Paysafe::REST::Client.new(api_secret: 'api_secret')
    refute client.credentials?
  end

  def test_verify
    result = VCR.use_cassette('verification') do
      authenticated_client.card_payments.verify_card(
        merchant_ref_num: random_id,
        number: '4111111111111111',
        month: 12,
        year: 2050,
        cvv: 123,
        address: {
          country: 'US',
          zip: '10014'
        }
      )
    end

    assert_match(/([a-f0-9\-]+)/, result.id)
    assert_match(/([a-f0-9\-]+)/, result.merchant_ref_num)
    assert_match(/([\d\-\:TZ]+)/, result.txn_time)
    assert_equal 'COMPLETED', result.status
    assert_equal 'VI', result.card.type
    assert_equal 'visa', result.card.brand
    assert_equal '1111', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal 2050, result.card.card_expiry.year
    assert_match(/\d+/, result.auth_code)
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'MATCH', result.avs_response
    assert_equal 'MATCH', result.cvv_verification
  end

  def test_get_profile
    result = VCR.use_cassette('get_profile') do
      profile = authenticated_client.customer_vault.create_profile(
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com'
      )
      authenticated_client.customer_vault.get_profile(id: profile.id)
    end

    assert_match(/([a-f0-9\-]+)/, result.id)
    assert_equal 'ACTIVE', result.status
    assert_equal 'en_US', result.locale
    assert_equal 'test', result.first_name
    assert_equal 'test', result.last_name
    assert_equal 'test@test.com', result.email
    refute_predicate result.merchant_customer_id, :empty?
    refute_predicate result.payment_token, :empty?
  end

  def test_get_profile_with_fields
    profile = VCR.use_cassette('get_profile_with_cards_and_addresses') do
      result = authenticated_client.customer_vault.create_profile(
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com',
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
      authenticated_client.customer_vault.get_profile(id: result.id, fields: [:cards,:addresses])
    end

    assert_match(/([a-f0-9\-]+)/, profile.id)
    assert_match(/([a-f0-9\-]+)/, profile.merchant_customer_id)
    assert profile.merchant_customer_id?
    assert_match(/([\w]+)/, profile.payment_token)
    assert profile.payment_token?
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email

    card = profile.cards.first
    assert_match(/([a-f0-9\-]+)/, card.id)
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match(/([a-f0-9\-]+)/, card.billing_address_id)
    assert_match(/([\w]+)/, card.payment_token)
    assert_equal 'ACTIVE', card.status

    address = profile.addresses.first
    assert_match(/([a-f0-9\-]+)/, address.id)
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_create_profile
    result = VCR.use_cassette('create_profile') do
      authenticated_client.customer_vault.create_profile(
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com'
      )
    end

    assert_match(/([a-f0-9\-]+)/, result.merchant_customer_id)
    assert_equal 'en_US', result.locale
    assert_equal 'test', result.first_name
    assert_equal 'test', result.last_name
    assert_equal 'test@test.com', result.email
    assert_equal 'ACTIVE', result.status
    assert result.payment_token?
  end

  def test_create_profile_failed
    error = assert_raises(Paysafe::Error::BadRequest) do
      VCR.use_cassette('create_profile_failed') do
        authenticated_client.customer_vault.create_profile(
          merchant_customer_id: '',
          locale: ''
        )
      end
    end

    assert_equal '5068', error.code
    assert_equal 'Either you submitted a request that is missing a mandatory field or the value of a field does not match the format expected.', error.message
  end

  def test_create_profile_with_card_and_address
    profile = VCR.use_cassette('create_profile_with_card_and_address') do
      authenticated_client.customer_vault.create_profile(
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com',
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

    assert profile.id?
    assert_match(/([a-f0-9\-]+)/, profile.merchant_customer_id)
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_match(/([\w]+)/, profile.payment_token)

    card = profile.cards.first
    assert_match(/([a-f0-9\-]+)/, card.id)
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match(/([a-f0-9\-]+)/, card.billing_address_id)
    assert_match(/([\w]+)/, card.payment_token)
    assert_equal 'ACTIVE', card.status

    address = profile.addresses.first
    assert_match(/([a-f0-9\-]+)/, address.id)
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_update_profile
    profile = VCR.use_cassette('update_profile') do
      profile = create_empty_profile
      assert_match(/([a-f0-9\-]+)/, profile.id)
      assert_nil profile.first_name
      assert_nil profile.last_name
      assert_nil profile.email

      authenticated_client.customer_vault.update_profile(
        id: profile.id,
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'Testing',
        last_name: 'Testing',
        email: 'example@test.com'
      )
    end

    assert_match(/([a-f0-9\-]+)/, profile.id)
    assert_match(/([a-f0-9\-]+)/, profile.merchant_customer_id)
    assert_equal 'en_US', profile.locale
    assert_equal 'Testing', profile.first_name
    assert_equal 'Testing', profile.last_name
    assert_equal 'example@test.com', profile.email
    assert_equal 'ACTIVE', profile.status
    assert_match(/([\w]+)/, profile.payment_token)
  end

  def test_create_address
    result = VCR.use_cassette('create_address') do
      profile = create_empty_profile
      authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )
    end

    assert_match(/([a-f0-9\-]+)/, result.id)
    assert_equal 'US', result.country
    assert_equal '10014', result.zip
    assert_equal 'ACTIVE', result.status
  end

  def test_delete_address
    VCR.use_cassette('delete_address') do
      profile = create_empty_profile
      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      authenticated_client.customer_vault.delete_address(
        profile_id: profile.id,
        id: address.id
      )
    end
  end

  def test_update_address
    result = VCR.use_cassette('update_address') do
      profile = create_empty_profile
      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      authenticated_client.customer_vault.update_address(
        profile_id: profile.id,
        id: address.id,
        country: 'US',
        zip: '10018'
      )
    end

    assert_match(/([a-f0-9\-]+)/, result.id)
    assert_equal 'US', result.country
    assert_equal '10018', result.zip
    assert_equal 'ACTIVE', result.status
  end

  def test_create_card
    card = VCR.use_cassette('create_card') do
      profile = create_empty_profile

      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        number: '4111111111111111',
        month: 12,
        year: 2050,
        billing_address_id: address.id
      )
    end

    assert_match(/([a-f0-9\-]+)/, card.id)
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match(/([a-f0-9\-]+)/, card.billing_address_id)
    assert_equal 'ACTIVE', card.status
    assert_match(/([\w]+)/, card.payment_token)
  end

  def test_create_card_failed_400
    error = assert_raises(Paysafe::Error::BadRequest) do
      VCR.use_cassette('create_card_failed_bad_request') do
        profile = create_empty_profile
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          number: '4111111111',
          month: 12,
          year: 2017
        )
      end
    end

    assert_equal "5068", error.code
    assert_equal 'Either you submitted a request that is missing a mandatory field or the value of a field does not match the format expected.', error.message
    assert error.response[:error][:field_errors].any?
  end

  def test_create_card_failed_409
    error = assert_raises(Paysafe::Error::Conflict) do
      VCR.use_cassette('create_card_failed_conflict') do
        profile = create_empty_profile
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          number: '4111111111111111',
          month: 12,
          year: 2050
        )

        # Should fail since card already exists
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          number: '4111111111111111',
          month: 12,
          year: 2050
        )
      end
    end

    assert_equal "7503", error.code
    assert_match(/Card number already in use -/, error.message)
  end

  def test_delete_card
    VCR.use_cassette('delete_card') do
      profile = create_empty_profile

      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      card = authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        number: '4111111111111111',
        month: 12,
        year: 2050,
        billing_address_id: address.id
      )

      authenticated_client.customer_vault.delete_card(profile_id: profile.id, id: card.id)
    end
  end

  def test_get_card
    card = VCR.use_cassette('get_card') do
      profile = create_empty_profile

      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      card = authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        number: '4111111111111111',
        month: 12,
        year: 2050,
        billing_address_id: address.id
      )

      authenticated_client.customer_vault.get_card(profile_id: profile.id, id: card.id)
    end

    assert_match(/([a-f0-9\-]+)/, card.id)
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match(/([a-f0-9\-]+)/, card.billing_address_id)
    assert_equal 'ACTIVE', card.status
    assert_match(/([\w]+)/, card.payment_token)
  end

  def test_update_card
    card = VCR.use_cassette('update_card') do
      profile = create_empty_profile

      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      card = authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        number: '4111111111111111',
        month: 12,
        year: 2050,
        billing_address_id: address.id
      )

      authenticated_client.customer_vault.update_card(
        profile_id: profile.id,
        id: card.id,
        month: 6,
        year: 2055
      )
    end

    assert_match(/([a-f0-9\-]+)/, card.id)
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 6, card.card_expiry.month
    assert_equal 2055, card.card_expiry.year
    assert_nil card.billing_address_id
    assert_equal 'ACTIVE', card.status
    assert_match(/([\w]+)/, card.payment_token)
  end

end
