require 'test_helper'

class CardPaymentsApiVerificationsTest < Minitest::Test

  def setup
    turn_on_vcr!
  end

  def teardown
    turn_off_vcr!
  end

  def test_create_verification
    result = VCR.use_cassette('card_payments_api/create_verification') do
      authenticated_client.card_payments.create_verification(
        merchant_ref_num: random_id,
        card: {
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: 123
        },
        billing_details: {
          country: 'US',
          zip: '10014'
        }
      )
    end

    assert_match UUID_REGEX, result.id
    assert_match UUID_REGEX, result.merchant_ref_num
    assert_equal 'COMPLETED', result.status
    assert_match(/\d+/, result.auth_code)
    assert_equal 'MATCH', result.avs_response
    assert_equal 'MATCH', result.cvv_verification
    assert_equal 'USD', result.currency_code
    assert Time.parse(result.txn_time)

    assert_equal 'VI', result.card.type
    assert_equal 'visa', result.card.brand
    assert_equal '1111', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal 2050, result.card.card_expiry.year

    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
  end

end
