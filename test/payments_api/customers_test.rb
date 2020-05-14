require 'test_helper'

class PaymentsApiCustomersTest < Minitest::Test

  def test_create_default_customer
    customer = VCR.use_cassette('payments_api/create_customer') do
      create_test_customer
    end

    assert_match UUID_REGEX, customer.id
    assert_match UUID_REGEX, customer.merchant_customer_id
    assert_match TOKEN_REGEX, customer.payment_token
    assert_equal "en_US", customer.locale
    assert_equal "ACTIVE", customer.status
  end

  def test_create_customer_with_optional_data
    customer = VCR.use_cassette('payments_api/create_customer_with_data') do
      create_test_customer(
        first_name: 'John',
        last_name: 'Smith',
        email: 'johnsmith@test.com',
        phone: '+12223334444'
      )
    end

    assert_match UUID_REGEX, customer.id
    assert_match UUID_REGEX, customer.merchant_customer_id
    assert_match TOKEN_REGEX, customer.payment_token
    assert_equal "en_US", customer.locale
    assert_equal "ACTIVE", customer.status
    assert_equal "John", customer.first_name
    assert_equal "Smith", customer.last_name
    assert_equal "johnsmith@test.com", customer.email
    assert_equal "+12223334444", customer.phone
  end

  def test_get_default_customer
    customer = VCR.use_cassette('payments_api/get_customer') do
      customer = create_test_customer
      unity_client.payments.get_customer(id: customer.id)
    end

    assert_match UUID_REGEX, customer.id
    assert_match UUID_REGEX, customer.merchant_customer_id
    assert_match TOKEN_REGEX, customer.payment_token
    assert_equal "en_US", customer.locale
    assert_equal "ACTIVE", customer.status
  end

end
