require 'test_helper'

class PaymentsApiSingleUseTokensTest < Minitest::Test

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
