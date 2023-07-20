require 'test_helper'

class PaymentsApiSingleUseTokensTest < Minitest::Test

  def test_create_single_use_customer_token_with_card
    sut_customer = VCR.use_cassette('payments_api/create_single_use_customer_token_with_card') do
      profile = create_test_profile_with_card_and_address
      unity_client.payments.create_single_use_customer_token(id: profile.id)
    end

    assert_match UUID_REGEX, sut_customer.id
    assert_match UUID_REGEX, sut_customer.customer_id
    assert_match TOKEN_REGEX, sut_customer.single_use_customer_token
    assert_instance_of Integer, sut_customer.time_to_live_seconds
    assert_equal "en_US", sut_customer.locale
    assert_equal "ACTIVE", sut_customer.status
    assert_equal "test", sut_customer.first_name
    assert_equal "test", sut_customer.last_name
    assert_equal "test@test.com", sut_customer.email

    assert_equal 1, sut_customer.payment_handles.count

    payment_handle = sut_customer.payment_handles.first
    assert_match UUID_REGEX, payment_handle.id
    assert_equal 'INITIATED', payment_handle.status
    assert_equal 'SINGLE_USE', payment_handle.usage
    assert_equal 'CARD', payment_handle.payment_type
    assert_match TOKEN_REGEX, payment_handle.payment_handle_token
    assert_match UUID_REGEX, payment_handle.billing_details_id
    assert_equal '411111', payment_handle.card.card_bin
    assert_equal '1111', payment_handle.card.last_digits
    assert_equal 'VI', payment_handle.card.card_type
    assert_equal 'visa', payment_handle.card.brand
    assert_equal '12', payment_handle.card.card_expiry.month
    assert_equal '2050', payment_handle.card.card_expiry.year

    assert_equal 1, sut_customer.addresses.count

    address = sut_customer.addresses.first
    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_create_single_use_customer_token
    single_use_token = VCR.use_cassette('payments_api/create_single_use_customer_token') do
      customer = create_test_customer
      unity_client.payments.create_single_use_customer_token(id: customer.id)
    end

    assert_match UUID_REGEX, single_use_token.id
    assert_match UUID_REGEX, single_use_token.customer_id
    assert_match TOKEN_REGEX, single_use_token.single_use_customer_token
    assert_instance_of Integer, single_use_token.time_to_live_seconds
    assert_equal "en_US", single_use_token.locale
    assert_equal "ACTIVE", single_use_token.status
  end

end
