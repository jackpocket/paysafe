require 'test_helper'

class CardPaymentsApiAuthorizationsTest < Minitest::Test

  def test_create_authorization
    auth = VCR.use_cassette('card_payments_api/create_authorization') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      authenticated_client.card_payments.create_authorization(
        amount: 4_00,
        merchant_ref_num: random_id,
        settle_with_auth: true,
        recurring: 'RECURRING',
        card: {
          payment_token: card.payment_token
        }
      )
    end

    assert_match UUID_REGEX, auth.id
    assert_match UUID_REGEX, auth.merchant_ref_num
    assert_equal 4_00, auth.amount
    assert_equal true, auth.settle_with_auth
    assert_equal false, auth.pre_auth
    assert_match AUTH_CODE_REGEX, auth.auth_code
    assert_equal 0, auth.available_to_settle
    assert_equal 'COMPLETED', auth.status
    assert_equal 'MATCH', auth.avs_response
    assert_equal 'NOT_PROCESSED', auth.cvv_verification
    assert_equal 'USD', auth.currency_code
    assert Time.parse(auth.txn_time)

    assert_equal 'test', auth.profile.first_name
    assert_equal 'test', auth.profile.last_name
    assert_equal 'test@test.com', auth.profile.email

    assert_equal 'VI', auth.card.type
    assert_equal 'visa', auth.card.brand
    assert_equal '1111', auth.card.last_digits
    assert_equal 12, auth.card.card_expiry.month
    assert_equal 2050, auth.card.card_expiry.year

    assert_equal 'US', auth.billing_details.country
    assert_equal '10014', auth.billing_details.zip
  end

  def test_create_authorization_failed_3009
    error = assert_raises(Paysafe::Error::RequestDeclined) do
      VCR.use_cassette('card_payments_api/create_authorization_failed_3009') do
        profile = create_test_profile_with_card_and_address
        card = profile.cards.first

        authenticated_client.card_payments.create_authorization(
          amount: 5, # simulate 3009 error code
          merchant_ref_num: random_id,
          settle_with_auth: true,
          recurring: 'RECURRING',
          card: {
            payment_token: card.payment_token
          }
        )
      end
    end

    assert_equal '3009', error.code
    assert_equal 'Your request has been declined by the issuing bank. (Code 3009)', error.message
    assert_match UUID_REGEX, error.id
    assert_match UUID_REGEX, error.merchant_ref_num
  end

  def test_create_purchase
    auth = VCR.use_cassette('card_payments_api/create_purchase') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      authenticated_client.purchase(
        amount: 4_00,
        token: card.payment_token,
        merchant_ref_num: random_id,
        recurring: 'RECURRING'
      )
    end

    assert_match UUID_REGEX, auth.id
    assert_match UUID_REGEX, auth.merchant_ref_num
    assert_equal 4_00, auth.amount
    assert_equal true, auth.settle_with_auth
    assert_equal false, auth.pre_auth
    assert_match AUTH_CODE_REGEX, auth.auth_code
    assert_equal 0, auth.available_to_settle
    assert_equal 'COMPLETED', auth.status
    assert_equal 'MATCH', auth.avs_response
    assert_equal 'NOT_PROCESSED', auth.cvv_verification
    assert_equal 'USD', auth.currency_code
    assert Time.parse(auth.txn_time)

    assert_equal 'test', auth.profile.first_name
    assert_equal 'test', auth.profile.last_name
    assert_equal 'test@test.com', auth.profile.email

    assert_equal 'VI', auth.card.type
    assert_equal 'visa', auth.card.brand
    assert_equal '1111', auth.card.last_digits
    assert_equal 12, auth.card.card_expiry.month
    assert_equal 2050, auth.card.card_expiry.year

    assert_equal 'US', auth.billing_details.country
    assert_equal '10014', auth.billing_details.zip
  end

  def test_get_authorization
    auth = VCR.use_cassette('card_payments_api/get_authorization') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      result = authenticated_client.card_payments.purchase(
        amount: 4_00,
        token: card.payment_token,
        merchant_ref_num: random_id,
        recurring: 'RECURRING'
      )
      authenticated_client.card_payments.get_authorization(id: result.id)
    end

    assert_match UUID_REGEX, auth.id
    assert_match UUID_REGEX, auth.merchant_ref_num
    assert_equal 4_00, auth.amount
    assert_equal true, auth.settle_with_auth
    assert_equal false, auth.pre_auth
    assert_match AUTH_CODE_REGEX, auth.auth_code
    assert_equal 0, auth.available_to_settle
    assert_equal 'COMPLETED', auth.status
    assert_equal 'MATCH', auth.avs_response
    assert_equal 'NOT_PROCESSED', auth.cvv_verification
    assert_equal 'USD', auth.currency_code
    assert Time.parse(auth.txn_time)

    assert_equal 'TEST', auth.profile.first_name
    assert_equal 'TEST', auth.profile.last_name
    assert_equal 'TEST@TEST.COM', auth.profile.email

    assert_equal 'VI', auth.card.type
    assert_equal 'visa', auth.card.brand
    assert_equal '1111', auth.card.last_digits
    assert_equal 12, auth.card.card_expiry.month
    assert_equal 2050, auth.card.card_expiry.year

    assert_equal 'US', auth.billing_details.country
    assert_equal '10014', auth.billing_details.zip
  end

end
