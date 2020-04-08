require 'test_helper'

class PaymentsApiPaymentsTest < Minitest::Test

  def test_create_payment
    payment = VCR.use_cassette('payments_api/create_payment', record: :none) do
      unity_client.payments.create_payment(
        merchant_ref_num: random_id,
        payment_handle_token: 'SSbLhbXLFnMksSAL',
        amount: 50_00,
        currency_code: 'USD'
      )
    end

    assert_match UUID_REGEX, payment.id
    assert_equal "SIGHTLINE", payment.payment_type
    assert_match TOKEN_REGEX, payment.payment_handle_token
    assert_match UUID_REGEX, payment.merchant_ref_num
    assert_equal "USD", payment.currency_code
    assert_equal true, payment.settle_with_auth
    assert Time.parse(payment.txn_time)
    assert_equal "COMPLETED", payment.status
    assert_match UUID_REGEX, payment.gateway_reconciliation_id
    assert_equal 50_00, payment.amount
    assert_equal 0, payment.available_to_settle
    assert_equal 50_00, payment.available_to_refund
    assert_match IP_ADDRESS_REGEX, payment.consumer_ip
    assert_equal false, payment.live_mode
    assert Time.parse(payment.updated_time)
    assert Time.parse(payment.status_time)

    assert_match TOKEN_REGEX, payment.sightline.consumer_id

    assert_equal "SIGHTLINE", payment.gateway_response.processor
    assert_match TOKEN_REGEX, payment.gateway_response.merchant_transaction_id
    assert_match UUID_REGEX, payment.gateway_response.payment_processor_transaction_id
    assert_match UUID_REGEX, payment.gateway_response.lcp_transaction_id
    assert_equal false, payment.gateway_response.lcp_encoded_transaction_id.empty?
    assert_match NUMBER_REGEX, payment.gateway_response.balance

    assert_equal "John", payment.profile.first_name
    assert_equal "Smith", payment.profile.last_name
    assert_equal "johnsmith@test.com", payment.profile.email
    assert_equal 1983, payment.profile.date_of_birth.year
    assert_equal 2, payment.profile.date_of_birth.month
    assert_equal 1, payment.profile.date_of_birth.day
    assert_equal "6464138000", payment.profile.phone

    assert_equal "353 West St", payment.billing_details.street1
    assert_equal "New York", payment.billing_details.city
    assert_equal "NY", payment.billing_details.state
    assert_equal "10014", payment.billing_details.zip
    assert_equal "US", payment.billing_details.country
  end

  def test_get_payment
    payment = VCR.use_cassette('payments_api/get_payment', record: :none) do
      unity_client.payments.get_payment(id: "33d4624e-847d-47e4-96dd-c832964bc9fb")
    end

    assert_match UUID_REGEX, payment.id
    assert_equal "SIGHTLINE", payment.payment_type
    assert_match TOKEN_REGEX, payment.payment_handle_token
    assert_match UUID_REGEX, payment.merchant_ref_num
    assert_equal "USD", payment.currency_code
    assert_equal true, payment.settle_with_auth
    assert Time.parse(payment.txn_time)
    assert_equal "COMPLETED", payment.status
    assert_match UUID_REGEX, payment.gateway_reconciliation_id
    assert_equal 50_00, payment.amount
    assert_equal 0, payment.available_to_settle
    assert_equal 50_00, payment.available_to_refund
    assert_match IP_ADDRESS_REGEX, payment.consumer_ip
    assert_equal false, payment.live_mode
    assert Time.parse(payment.updated_time)
    assert Time.parse(payment.status_time)

    assert_match TOKEN_REGEX, payment.sightline.consumer_id

    assert_equal "SIGHTLINE", payment.gateway_response.processor
    assert_match TOKEN_REGEX, payment.gateway_response.merchant_transaction_id
    assert_match UUID_REGEX, payment.gateway_response.payment_processor_transaction_id
    assert_match UUID_REGEX, payment.gateway_response.lcp_transaction_id
    assert_equal false, payment.gateway_response.lcp_encoded_transaction_id.empty?
    assert_match NUMBER_REGEX, payment.gateway_response.balance

    assert_equal "John", payment.profile.first_name
    assert_equal "Smith", payment.profile.last_name
    assert_equal "johnsmith@test.com", payment.profile.email
    assert_equal 1983, payment.profile.date_of_birth.year
    assert_equal 2, payment.profile.date_of_birth.month
    assert_equal 1, payment.profile.date_of_birth.day
    assert_equal "6464138000", payment.profile.phone

    assert_equal "353 West St", payment.billing_details.street1
    assert_equal "New York", payment.billing_details.city
    assert_equal "NY", payment.billing_details.state
    assert_equal "10014", payment.billing_details.zip
    assert_equal "US", payment.billing_details.country
  end

end
