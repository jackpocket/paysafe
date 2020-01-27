require 'test_helper'

class CardPaymentsApiVerificationsTest < Minitest::Test

  def test_create_verification
    verification = VCR.use_cassette('card_payments_api/create_verification') do
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

    assert_match UUID_REGEX, verification.id
    assert_match UUID_REGEX, verification.merchant_ref_num
    assert_equal 'COMPLETED', verification.status
    assert_match AUTH_CODE_REGEX, verification.auth_code
    assert_equal 'MATCH', verification.avs_response
    assert verification.avs_match?
    assert_equal 'MATCH', verification.cvv_verification
    assert verification.cvv_match?
    assert_equal 'USD', verification.currency_code
    assert Time.parse(verification.txn_time)

    assert_equal 'VI', verification.card.type
    assert_equal 'visa', verification.card.brand
    assert_equal '1111', verification.card.last_digits
    assert_equal 12, verification.card.card_expiry.month
    assert_equal 2050, verification.card.card_expiry.year

    assert_equal 'US', verification.billing_details.country
    assert_equal '10014', verification.billing_details.zip
  end

  def test_get_verification
    verification = VCR.use_cassette('card_payments_api/get_verification') do
      result = authenticated_client.card_payments.create_verification(
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
      authenticated_client.card_payments.get_verification(id: result.id)
    end

    assert_match UUID_REGEX, verification.id
    assert_match UUID_REGEX, verification.merchant_ref_num
    assert_equal 'COMPLETED', verification.status
    assert_match AUTH_CODE_REGEX, verification.auth_code
    assert_equal 'MATCH', verification.avs_response
    assert verification.avs_match?
    assert_equal 'MATCH', verification.cvv_verification
    assert verification.cvv_match?
    assert_equal 'USD', verification.currency_code
    assert Time.parse(verification.txn_time)

    assert_equal 'VI', verification.card.type
    assert_equal 'visa', verification.card.brand
    assert_equal '1111', verification.card.last_digits
    assert_equal 12, verification.card.card_expiry.month
    assert_equal 2050, verification.card.card_expiry.year

    assert_equal 'US', verification.billing_details.country
    assert_equal '10014', verification.billing_details.zip
  end

end
