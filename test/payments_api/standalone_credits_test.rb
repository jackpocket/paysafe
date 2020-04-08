require 'test_helper'

class PaymentsApiStandaloneCreditsTest < Minitest::Test

  def test_create_standalone_credit
    standalone_credit = VCR.use_cassette('payments_api/create_standalone_credit', record: :none) do
      unity_client.payments.create_standalone_credit(
        merchant_ref_num: random_id,
        payment_handle_token: 'SSa1YzvnJT6S4Hss',
        amount: 65_00,
        currency_code: 'USD'
      )
    end

    assert_match UUID_REGEX, standalone_credit.id
    assert_equal "SIGHTLINE", standalone_credit.payment_type
    assert_match TOKEN_REGEX, standalone_credit.payment_handle_token
    assert_match UUID_REGEX, standalone_credit.merchant_ref_num
    assert_equal "USD", standalone_credit.currency_code
    assert Time.parse(standalone_credit.txn_time)
    assert_equal "COMPLETED", standalone_credit.status
    assert_match UUID_REGEX, standalone_credit.gateway_reconciliation_id
    assert_equal 65_00, standalone_credit.amount
    assert_equal false, standalone_credit.live_mode
    assert Time.parse(standalone_credit.updated_time)
    assert Time.parse(standalone_credit.status_time)

    assert_match TOKEN_REGEX, standalone_credit.sightline.consumer_id

    assert_equal "SIGHTLINE", standalone_credit.gateway_response.processor
    assert_match TOKEN_REGEX, standalone_credit.gateway_response.merchant_transaction_id
    assert_match UUID_REGEX, standalone_credit.gateway_response.payment_processor_transaction_id
    assert_match UUID_REGEX, standalone_credit.gateway_response.lcp_transaction_id
    assert_equal false, standalone_credit.gateway_response.lcp_encoded_transaction_id.empty?
    assert_match NUMBER_REGEX, standalone_credit.gateway_response.balance

    assert_equal "John", standalone_credit.profile.first_name
    assert_equal "Smith", standalone_credit.profile.last_name
    assert_equal "johnsmith@test.com", standalone_credit.profile.email
    assert_equal 1983, standalone_credit.profile.date_of_birth.year
    assert_equal 2, standalone_credit.profile.date_of_birth.month
    assert_equal 1, standalone_credit.profile.date_of_birth.day
    assert_equal "6464138000", standalone_credit.profile.phone

    assert_equal "353 West St", standalone_credit.billing_details.street1
    assert_equal "New York", standalone_credit.billing_details.city
    assert_equal "NY", standalone_credit.billing_details.state
    assert_equal "10014", standalone_credit.billing_details.zip
    assert_equal "US", standalone_credit.billing_details.country
  end

  def test_get_standalone_credit
    standalone_credit = VCR.use_cassette('payments_api/get_standalone_credit', record: :none) do
      unity_client.payments.get_standalone_credit(id: "b529e9c2-6ece-4fde-8f63-de9bcf002063")
    end

    assert_match UUID_REGEX, standalone_credit.id
    assert_equal "SIGHTLINE", standalone_credit.payment_type
    assert_match TOKEN_REGEX, standalone_credit.payment_handle_token
    assert_match UUID_REGEX, standalone_credit.merchant_ref_num
    assert_equal "USD", standalone_credit.currency_code
    assert Time.parse(standalone_credit.txn_time)
    assert_equal "COMPLETED", standalone_credit.status
    assert_match UUID_REGEX, standalone_credit.gateway_reconciliation_id
    assert_equal 65_00, standalone_credit.amount
    assert_equal false, standalone_credit.live_mode
    assert Time.parse(standalone_credit.updated_time)
    assert Time.parse(standalone_credit.status_time)

    assert_match TOKEN_REGEX, standalone_credit.sightline.consumer_id

    assert_equal "SIGHTLINE", standalone_credit.gateway_response.processor
    assert_match TOKEN_REGEX, standalone_credit.gateway_response.merchant_transaction_id
    assert_match UUID_REGEX, standalone_credit.gateway_response.payment_processor_transaction_id
    assert_match UUID_REGEX, standalone_credit.gateway_response.lcp_transaction_id
    assert_equal false, standalone_credit.gateway_response.lcp_encoded_transaction_id.empty?
    assert_match NUMBER_REGEX, standalone_credit.gateway_response.balance

    assert_equal "John", standalone_credit.profile.first_name
    assert_equal "Smith", standalone_credit.profile.last_name

    assert_equal "353 West St", standalone_credit.billing_details.street1
    assert_equal "New York", standalone_credit.billing_details.city
    assert_equal "NY", standalone_credit.billing_details.state
    assert_equal "10014", standalone_credit.billing_details.zip
    assert_equal "US", standalone_credit.billing_details.country
  end

end
