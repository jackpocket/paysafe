require 'test_helper'

class CamelCaseTest < Minitest::Test

  using ::Paysafe::Refinements::CamelCase

  def test_hash_conversion
    hash = {
      merchant_ref_num: 123,
      payment_token: 'def',
      email: 'test@test.com',
      card: {
        single_use_token: 'abc',
        billing_address: {
          country: 'US'
        }
      }
    }

    expected = {
      merchantRefNum: 123,
      paymentToken: 'def',
      email: 'test@test.com',
      card: {
        singleUseToken: 'abc',
        billingAddress: {
          country: 'US'
        }
      }
    }

    assert_equal expected, hash.to_camel_case
  end

  def test_nested_array_conversion
    hash = {
      id: 'abc',
      merchant_customer_id: '456def',
      addresses: [
        {
          id: 'abc123',
          default_shipping_address_indicator: false,
        }
      ],
      cards: [
        {
          status: 'ACTIVE',
          card_bin: '123456',
          billing_address_id: 'test',
          card_expiry: {
            month: 4,
            year: 2017,
          }
        }
      ]
    }

    expected = {
      id: 'abc',
      merchantCustomerId: '456def',
      addresses: [
        {
          id: 'abc123',
          defaultShippingAddressIndicator: false,
        }
      ],
      cards: [
        {
          status: 'ACTIVE',
          cardBin: '123456',
          billingAddressId: 'test',
          cardExpiry: {
            month: 4,
            year: 2017,
          }
        }
      ]
    }

    assert_equal expected, hash.to_camel_case
  end

end
