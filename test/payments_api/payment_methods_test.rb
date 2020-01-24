require 'test_helper'

class PaymentsApiPaymentMethodsTest < Minitest::Test

  def test_get_payment_methods
    result = VCR.use_cassette('payments_api/get_payment_methods', record: :none, erb: { account_id: '123' }) do
      unity_client.payments.get_payment_methods(currency_code: 'USD')
    end

    assert_equal 1, result.payment_methods.size

    assert_equal "SIGHTLINE", result.payment_methods.first.payment_method
    assert_equal "123", result.payment_methods.first.account_id
    assert_equal "8999", result.payment_methods.first.mcc
    assert_equal "USD", result.payment_methods.first.currency_code
    assert_equal "USD", result.payment_methods.first.currency
  end

end
