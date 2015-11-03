require 'test_helper'

class OptimalPaymentsTest < Minitest::Test

  def setup
    turn_on_vcr!
  end

  def test_that_it_has_a_version_number
    refute_nil ::OptimalPayments::VERSION
  end

  def test_client_is_configured_through_options
    client = OptimalPayments::REST::Client.new(
      account_number: 'account_number',
      api_key: 'api_key',
      api_secret: 'api_secret',
      test_mode: false
    )

    assert_equal client.account_number, 'account_number'
    assert_equal client.api_key, 'api_key'
    assert_equal client.api_secret, 'api_secret'
    assert_equal client.test_mode, false
  end

  def test_client_is_configured_with_block
    client = OptimalPayments::REST::Client.new do |config|
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
    client = OptimalPayments::REST::Client.new(test_mode: true)

    assert_equal client.test_mode, true
    assert_equal client.api_base, 'https://api.test.netbanx.com'

    client = OptimalPayments::REST::Client.new(test_mode: false)

    assert_equal client.test_mode, false
    assert_equal client.api_base, 'https://api.netbanx.com'
  end

  def test_credentials?
    assert test_client.credentials?

    client = OptimalPayments::REST::Client.new(account_number: 'account_number')

    refute client.credentials?
  end

  def test_verify
    VCR.use_cassette('verification') do
      result = test_client.verify(
        merchantRefNum: '1445638620',
        card: {
          cardNum: '4111111111111111',
          cardExpiry: {
            month: 6,
            year: 2019
          },
          cvv: 123
        },
        address: {
          country: 'US',
          zip: '10014'
        }
      )

      assert_kind_of Hash, result
      assert_equal '28e1c0ab-d118-43ad-bdb7-638702826e1b', result[:id]
      assert_equal '1445638620', result[:merchantRefNum]
      assert_equal '2015-10-29T22:01:11Z', result[:txnTime]
      assert_equal 'COMPLETED', result[:status]
      assert_equal 'VI', result[:card][:type]
      assert_equal '1111', result[:card][:lastDigits]
      assert_equal 6, result[:card][:cardExpiry][:month]
      assert_equal 2019, result[:card][:cardExpiry][:year]
      assert_equal 'XXXXXX', result[:authCode]
      assert_equal 'US', result[:billingDetails][:country]
      assert_equal '10014', result[:billingDetails][:zip]
      assert_equal 'USD', result[:currencyCode]
      assert_equal 'MATCH_ZIP_ONLY', result[:avsResponse]
      assert_equal 'MATCH', result[:cvvVerification]
    end
  end

  def test_get_profile
    VCR.use_cassette('get_profile') do
      result = test_client.get_profile(id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed')

      assert_kind_of Hash, result
      assert_equal 'b088ac37-32cb-4320-9b64-f9f4923f53ed', result[:id]
      assert_equal 'ACTIVE', result[:status]
      assert_equal 'en_US', result[:locale]
      assert_equal 'John', result[:firstName]
      assert_equal 'Snakes', result[:lastName]
      assert_equal 'test@test.com', result[:email]
      refute_predicate result[:merchantCustomerId], :empty?
      refute_predicate result[:paymentToken], :empty?
    end
  end

  def test_get_profile_with_fields
    VCR.use_cassette('get_profile_with_cards_and_addresses') do
      profile = test_client.get_profile(id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', fields: [:cards,:addresses])

      assert_kind_of Hash, profile
      assert_equal 'b088ac37-32cb-4320-9b64-f9f4923f53ed', profile[:id]
      assert_equal 'ACTIVE', profile[:status]
      assert_equal 'en_US', profile[:locale]
      assert_equal 'John', profile[:firstName]
      assert_equal 'Snakes', profile[:lastName]
      assert_equal 'test@test.com', profile[:email]
      refute_predicate profile[:merchantCustomerId], :empty?
      refute_predicate profile[:paymentToken], :empty?

      card = profile[:cards][0]
      assert_kind_of Hash, card
      assert_equal '7f7513cd-f5ea-49c5-a249-72050bc750e7', card[:id]
      assert_equal '411111', card[:cardBin]
      assert_equal '1111', card[:lastDigits]
      assert_equal 12, card[:cardExpiry][:month]
      assert_equal 2019, card[:cardExpiry][:year]
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', card[:billingAddressId]
      assert_equal 'VI', card[:cardType]
      assert_equal 'CNpnmxFwDSK3s9p', card[:paymentToken]
      assert_equal 'ACTIVE', card[:status]

      address = profile[:addresses][0]
      assert_kind_of Hash, address
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', address[:id]
      assert_equal 'US', address[:country]
      assert_equal '10014', address[:zip]
      assert_equal 'ACTIVE', address[:status]
    end
  end

  def test_create_profile
    VCR.use_cassette('create_profile') do
      result = test_client.create_profile(merchantCustomerId: '1445638620', locale: 'en_US', firstName: 'test', lastName: 'test', email: 'test@test.com')

      assert_kind_of Hash, result
      assert_equal '1445638620', result[:merchantCustomerId]
      assert_equal 'en_US', result[:locale]
      assert_equal 'test', result[:firstName]
      assert_equal 'test', result[:lastName]
      assert_equal 'test@test.com', result[:email]
      assert_equal 'ACTIVE', result[:status]
      refute_predicate result[:paymentToken], :empty?
    end
  end

  def test_create_profile_with_card_and_address
    VCR.use_cassette('create_profile_with_card_and_address') do
      profile = test_client.create_profile(
        merchantCustomerId: '1446069505',
        locale: 'en_US',
        firstName: 'test',
        lastName: 'test',
        email: 'test@test.com',
        card: {
          cardNum: '4111111111111111',
          cardExpiry: {
            month: 12,
            year: 2019
          },
          billingAddress: {
            country: 'US', zip: '10014'
          }
        }
      )

      assert_kind_of Hash, profile
      assert_equal '1446069505', profile[:merchantCustomerId]
      assert_equal 'en_US', profile[:locale]
      assert_equal 'test', profile[:firstName]
      assert_equal 'test', profile[:lastName]
      assert_equal 'test@test.com', profile[:email]
      assert_equal 'ACTIVE', profile[:status]
      assert_equal 'PovQX1RKgd8daYh', profile[:paymentToken]

      address = profile[:addresses][0]

      assert_kind_of Hash, address
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', address[:id]
      assert_equal 'US', address[:country]
      assert_equal '10014', address[:zip]
      assert_equal 'ACTIVE', address[:status]

      card = profile[:cards][0]

      assert_kind_of Hash, card
      assert_equal '7f7513cd-f5ea-49c5-a249-72050bc750e7', card[:id]
      assert_equal 12, card[:cardExpiry][:month]
      assert_equal 2019, card[:cardExpiry][:year]
      assert_equal '6146cd5e-b7bd-4867-870e-0adc910d01df', card[:billingAddressId]
      assert_equal 'ACTIVE', card[:status]
    end
  end

  def test_create_profile_with_card_and_address_failed
    VCR.use_cassette('create_profile_with_card_and_address_failed') do
      assert_raises(OptimalPayments::Error::Conflict) do
        test_client.create_profile(
          merchantCustomerId: '1445638620',
          locale: 'en_US',
          firstName: 'test',
          lastName: 'test',
          email: 'test@test.com',
          card: {
            cardNum: '4111111111111111',
            cardExpiry: {
              month: 12,
              year: 2019
            },
            billingAddress: {
              country: 'US', zip: '10014'
            }
          }
        )
      end
    end
  end

  def test_create_address
    VCR.use_cassette('create_address') do
      result = test_client.create_address(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', country: 'US', zip: '10014')

      assert_kind_of Hash, result
      assert_equal 'US', result[:country]
      assert_equal '10014', result[:zip]
      assert_equal 'ACTIVE', result[:status]
    end
  end

  def test_create_card
    VCR.use_cassette('create_card') do
      result = test_client.create_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', number: '4111111111111111', month: 12, year: 2019, billingAddressId: '4bf9d2e7-4be0-4d13-b483-223640cb40a0')

      assert_kind_of Hash, result
      assert_equal 'd63b2910-9ab5-4803-a2a2-1aadcc790cc2', result[:id]
      assert_equal '411111', result[:cardBin]
      assert_equal '1111', result[:lastDigits]
      assert_equal 12, result[:cardExpiry][:month]
      assert_equal 2019, result[:cardExpiry][:year]
      assert_equal 'VI', result[:cardType]
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', result[:billingAddressId]
      assert_equal 'ACTIVE', result[:status]
      assert_equal 'CHHzoulx4Xpm31I', result[:paymentToken]
    end
  end

  def test_create_card_failed_400
    VCR.use_cassette('create_card_failed_400') do
      assert_raises(OptimalPayments::Error::BadRequest) {
        test_client.create_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', number: '4111111111', month: 12, year: 2017)
      }
    end
  end

  def test_create_card_failed_409
    VCR.use_cassette('create_card_failed_409') do
      assert_raises(OptimalPayments::Error::Conflict) {
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
      result = test_client.get_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', id: '972ed74f-6ff1-4a5b-a460-a11e606e2fa9')

      assert_kind_of Hash, result
      assert_equal '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', result[:id]
      assert_equal '411111', result[:cardBin]
      assert_equal '1111', result[:lastDigits]
      assert_equal 12, result[:cardExpiry][:month]
      assert_equal 2017, result[:cardExpiry][:year]
      assert_equal 'VI', result[:cardType]
      assert_equal 'John Smith', result[:holderName]
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', result[:billingAddressId]
      assert_equal 'ACTIVE', result[:status]
      assert_equal 'CdZk1Yk5EUSJb2v', result[:paymentToken]
    end
  end

  def test_update_card
    VCR.use_cassette('update_card') do
      result = test_client.update_card(profile_id: 'b088ac37-32cb-4320-9b64-f9f4923f53ed', id: '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', month: 6, year: 2019)

      assert_kind_of Hash, result
      assert_equal '972ed74f-6ff1-4a5b-a460-a11e606e2fa9', result[:id]
      assert_equal '411111', result[:cardBin]
      assert_equal '1111', result[:lastDigits]
      assert_equal 6, result[:cardExpiry][:month]
      assert_equal 2019, result[:cardExpiry][:year]
      assert_equal 'VI', result[:cardType]
      assert_equal 'Johnny Smith', result[:holderName]
      assert_equal '4bf9d2e7-4be0-4d13-b483-223640cb40a0', result[:billingAddressId]
      assert_equal 'ACTIVE', result[:status]
      assert_equal 'CNBkqXXjTFdZNa3', result[:paymentToken]
    end
  end

  def test_purchase
    VCR.use_cassette('purchase') do
      result = test_client.purchase(amount: 400, token: 'CrHElYip7kRAgXY', merchantRefNum: '1445888963')

      assert_kind_of Hash, result
      refute_predicate result[:id], :empty?
      assert_equal 400, result[:amount]
      assert_equal true, result[:settleWithAuth]
      assert_equal '1445888963', result[:merchantRefNum]
      refute_predicate result[:txnTime], :empty?
      assert_equal 'COMPLETED', result[:status]
      assert_equal 'USD', result[:currencyCode]
      assert_equal 'NOT_PROCESSED', result[:avsResponse]
      refute_predicate result[:card], :empty?
      refute_predicate result[:profile], :empty?
      refute_predicate result[:billingDetails], :empty?
      refute_predicate result[:authCode], :empty?
    end
  end

end
