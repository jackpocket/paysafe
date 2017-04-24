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

  def test_client_is_configured_with_block
    client = Paysafe::REST::Client.new do |config|
      config.account_number = 'account_number'
      config.api_key = 'api_key'
      config.api_secret = 'api_secret'
      config.test_mode = false
    end

    assert_equal client.account_number, 'account_number'
    assert_equal client.api_key, 'api_key'
    assert_equal client.api_secret, 'api_secret'
    assert_equal client.test_mode, false
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
    assert test_client.credentials?

    client = Paysafe::REST::Client.new(api_key: 'api_key')

    refute client.credentials?
  end

  def test_verify
    VCR.use_cassette('verification') do
      result = test_client.verify_card(
        merchant_ref_num: '1445638620',
        number: '4111111111111111',
        month: 6,
        year: 2019,
        cvv: 123,
        address: {
          country: 'US',
          zip: '10014'
        }
      )

      assert_equal '28e1c0ab-d118-43ad-bdb7-638702826e1b', result.id
      assert_equal '1445638620', result.merchant_ref_num
      assert_equal '2015-10-29T22:01:11Z', result.txn_time
      assert_equal 'COMPLETED', result.status
      assert_equal 'VI', result.card.type
      assert_equal 'visa', result.card.brand
      assert_equal '1111', result.card.last_digits
      assert_equal 6, result.card.card_expiry.month
      assert_equal 2019, result.card.card_expiry.year
      assert_equal 'XXXXXX', result.auth_code
      assert_equal 'US', result.billing_details.country
      assert_equal '10014', result.billing_details.zip
      assert_equal 'USD', result.currency_code
      assert_equal 'MATCH_ZIP_ONLY', result.avs_response
      assert_equal 'MATCH', result.cvv_verification
    end
  end

  def test_get_profile
    VCR.use_cassette('get_profile') do
      result = test_client.get_profile(id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed')

      assert_equal 'b088ac37-32cb-4320-9b64-f9f4923f53ed', result.id
      assert_equal 'ACTIVE', result.status
      assert_equal 'en_US', result.locale
      assert_equal 'John', result.first_name
      assert_equal 'Snakes', result.last_name
      assert_equal 'test@test.com', result.email
      refute_predicate result.merchant_customer_id, :empty?
      refute_predicate result.payment_token, :empty?
    end
  end

  def test_get_profile_with_fields
    VCR.use_cassette('get_profile_with_cards_and_addresses') do
      profile = test_client.get_profile(id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', fields: [:cards,:addresses])

      assert_equal 'b088ac37-32cb-4320-9b64-f9f4923f53ed', profile.id
      assert_equal 'ACTIVE', profile.status
      assert_equal 'en_US', profile.locale
      assert_equal 'John', profile.first_name
      assert_equal 'Snakes', profile.last_name
      assert_equal 'test@test.com', profile.email
      assert profile.merchant_customer_id?
      assert profile.payment_token?

      card = profile.cards.first
      assert_equal '7f7513cd-f5ea-49c5-a249-72050bc750e7', card.id
      assert_equal '411111', card.card_bin
      assert_equal '1111', card.last_digits
      assert_equal 'VI', card.card_type
      assert_equal 'visa', card.brand
      assert_equal 12, card.card_expiry.month
      assert_equal 2019, card.card_expiry.year
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', card.billing_address_id
      assert_equal 'VI', card.card_type
      assert_equal 'CNpnmxFwDSK3s9p', card.payment_token
      assert_equal 'ACTIVE', card.status

      address = profile.addresses.first
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', address.id
      assert_equal 'US', address.country
      assert_equal '10014', address.zip
      assert_equal 'ACTIVE', address.status
    end
  end

  def test_create_profile
    VCR.use_cassette('create_profile') do
      result = test_client.create_profile(merchant_customer_id: '1445638620', locale: 'en_US', first_name: 'test', last_name: 'test', email: 'test@test.com')

      assert_equal '1445638620', result.merchant_customer_id
      assert_equal 'en_US', result.locale
      assert_equal 'test', result.first_name
      assert_equal 'test', result.last_name
      assert_equal 'test@test.com', result.email
      assert_equal 'ACTIVE', result.status
      assert result.payment_token?
    end
  end

  def test_create_profile_with_card_and_address
    VCR.use_cassette('create_profile_with_card_and_address') do
      profile = test_client.create_profile(
        merchant_customer_id: '1446069505',
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com',
        card: {
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2019
          },
          billing_address: {
            country: 'US', zip: '10014'
          }
        }
      )

      assert profile.id?
      assert_equal '1446069505', profile.merchant_customer_id
      assert_equal 'ACTIVE', profile.status
      assert_equal 'en_US', profile.locale
      assert_equal 'test', profile.first_name
      assert_equal 'test', profile.last_name
      assert_equal 'test@test.com', profile.email
      assert_equal 'PovQX1RKgd8daYh', profile.payment_token

      card = profile.cards.first
      assert_equal '7f7513cd-f5ea-49c5-a249-72050bc750e7', card.id
      assert_equal '411111', card.card_bin
      assert_equal '1111', card.last_digits
      assert_equal 'VI', card.card_type
      assert_equal 'visa', card.brand
      assert_equal 12, card.card_expiry.month
      assert_equal 2019, card.card_expiry.year
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', card.billing_address_id
      assert_equal 'VI', card.card_type
      assert_equal 'CNpnmxFwDSK3s9p', card.payment_token
      assert_equal 'ACTIVE', card.status

      address = profile.addresses.first
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', address.id
      assert_equal 'US', address.country
      assert_equal '10014', address.zip
      assert_equal 'ACTIVE', address.status
    end
  end

  def test_create_profile_with_card_and_address_failed
    VCR.use_cassette('create_profile_with_card_and_address_failed') do
      assert_raises(Paysafe::Error::Conflict) do
        test_client.create_profile(
          merchant_customer_id: '1445638620',
          locale: 'en_US',
          first_name: 'test',
          last_name: 'test',
          email: 'test@test.com',
          card: {
            card_num: '4111111111111111',
            card_expiry: {
              month: 12,
              year: 2019
            },
            billing_address: {
              country: 'US', zip: '10014'
            }
          }
        )
      end
    end
  end

  def test_update_profile
    VCR.use_cassette('update_profile') do
      profile = test_client.update_profile(
        id: '0978224b-5116-48d4-8a8e-e4b5b7a32285',
        merchant_customer_id: '1445638620',
        locale: 'en_US',
        first_name: 'Testing',
        last_name: 'Testing',
        email: 'example@test.com'
      )

      assert_equal '1445638620', profile.merchant_customer_id
      assert_equal 'en_US', profile.locale
      assert_equal 'Testing', profile.first_name
      assert_equal 'Testing', profile.last_name
      assert_equal 'example@test.com', profile.email
      assert_equal 'ACTIVE', profile.status
      assert_equal 'PSs8LGTqy2y2PcY', profile.payment_token
    end
  end

  def test_create_address
    VCR.use_cassette('create_address') do
      result = test_client.create_address(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', country: 'US', zip: '10014')

      assert_equal 'US', result.country
      assert_equal '10014', result.zip
      assert_equal 'ACTIVE', result.status
    end
  end

  def test_create_card
    VCR.use_cassette('create_card') do
      card = test_client.create_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', number: '4111111111111111', month: 12, year: 2019, billing_address_id: '4bf9d2e7-4be0-4d13-b483-223640cb40a0')

      assert_equal 'd63b2910-9ab5-4803-a2a2-1aadcc790cc2', card.id
      assert_equal '411111', card.card_bin
      assert_equal '1111', card.last_digits
      assert_equal 'VI', card.card_type
      assert_equal 'visa', card.brand
      assert_equal 12, card.card_expiry.month
      assert_equal 2019, card.card_expiry.year
      assert_equal 'VI', card.card_type
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', card.billing_address_id
      assert_equal 'ACTIVE', card.status
      assert_equal 'CHHzoulx4Xpm31I', card.payment_token
    end
  end

  def test_create_card_failed_400
    VCR.use_cassette('create_card_failed_400') do
      error = assert_raises(Paysafe::Error::BadRequest) {
        test_client.create_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', number: '4111111111', month: 12, year: 2017)
      }

      # Converts response keys to snake_case
      assert error.response[:error][:field_errors].any?
    end
  end

  def test_create_card_failed_409
    VCR.use_cassette('create_card_failed_409') do
      assert_raises(Paysafe::Error::Conflict) {
        test_client.create_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', number: '4111111111111111', month: 12, year: 2019)
      }
    end
  end

  def test_delete_card
    VCR.use_cassette('delete_card') do
      test_client.delete_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', id: '8e176fa6-9803-40a3-b870-0cd1fdb0e64e')
    end
  end

  def test_get_card
    VCR.use_cassette('get_card') do
      card = test_client.get_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', id: '972ed74f-6ff1-4a5b-a460-a11e606e2fa9')

      assert_equal '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', card.id
      assert_equal '411111', card.card_bin
      assert_equal '1111', card.last_digits
      assert_equal 'VI', card.card_type
      assert_equal 'visa', card.brand
      assert_equal 12, card.card_expiry.month
      assert_equal 2017, card.card_expiry.year
      assert_equal 'John Smith', card.holder_name
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', card.billing_address_id
      assert_equal 'ACTIVE', card.status
      assert_equal 'CdZk1Yk5EUSJb2v', card.payment_token
    end
  end

  def test_update_card
    VCR.use_cassette('update_card') do
      card = test_client.update_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', id: '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', month: 6, year: 2019)

      assert_equal '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', card.id
      assert_equal '411111', card.card_bin
      assert_equal '1111', card.last_digits
      assert_equal 'VI', card.card_type
      assert_equal 'visa', card.brand
      assert_equal 6, card.card_expiry.month
      assert_equal 2019, card.card_expiry.year
      assert_equal 'John Smith', card.holder_name
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', card.billing_address_id
      assert_equal 'ACTIVE', card.status
      assert_equal 'CNBkqXXjTFdZNa3', card.payment_token
    end
  end

  def test_purchase
    VCR.use_cassette('purchase') do
      result = test_client.purchase(amount: 400, token: 'CrHElYip7kRAgXY', merchant_ref_num: '1445888963')

      assert result.id?
      assert_equal 400, result.amount
      assert_equal true, result.settle_with_auth
      assert_equal '1445888963', result.merchant_ref_num
      assert result.txn_time?
      assert_equal 'COMPLETED', result.status
      assert_equal 'USD', result.currency_code
      assert_equal 'NOT_PROCESSED', result.avs_response
      assert_equal '100550', result.auth_code
      assert result.card?
      assert result.profile?
      assert result.billing_details?
    end
  end

end
