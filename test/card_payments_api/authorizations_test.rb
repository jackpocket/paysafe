require 'test_helper'

class CardPaymentsApiAuthorizationsTest < Minitest::Test

  def setup
    turn_on_vcr!
  end

  def teardown
    turn_off_vcr!
  end

  def test_create_purchase
    result = VCR.use_cassette('card_payments_api/create_purchase') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      authenticated_client.purchase(
        amount: 4_00,
        token: card.payment_token,
        merchant_ref_num: random_id,
        recurring: 'RECURRING'
      )
    end

    assert_match UUID_REGEX, result.id
    assert_match UUID_REGEX, result.merchant_ref_num
    assert_equal 4_00, result.amount
    assert_equal true, result.settle_with_auth
    assert_equal false, result.pre_auth
    assert_match AUTH_CODE_REGEX, result.auth_code
    assert_equal 0, result.available_to_settle
    assert_equal 'COMPLETED', result.status
    assert_equal 'MATCH', result.avs_response
    assert_equal 'NOT_PROCESSED', result.cvv_verification
    assert_equal 'USD', result.currency_code
    assert Time.parse(result.txn_time)

    assert_equal 'test', result.profile.first_name
    assert_equal 'test', result.profile.last_name
    assert_equal 'test@test.com', result.profile.email

    assert_equal 'VI', result.card.type
    assert_equal 'visa', result.card.brand
    assert_equal '1111', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal 2050, result.card.card_expiry.year

    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
  end

end
