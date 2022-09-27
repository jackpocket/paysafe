require 'test_helper'

class CustomerVaultApiSingleUseTokensTest < Minitest::Test

  def test_create_single_use_token
    sut = VCR.use_cassette('customer_vault_api/create_single_use_token') do
      sut_client.customer_vault.create_single_use_token(
        card: {
          card_num: '5200400000000009',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: '123',
          billing_address: {
            country: 'US',
            zip: '10014'
          }
        }
      )
    end

    assert_match UUID_REGEX, sut.id
    assert_match TOKEN_REGEX, sut.payment_token
    assert_equal '520040', sut.card.card_bin
    assert_equal '0009', sut.card.last_digits
    assert_equal 'MC', sut.card.card_type
    assert_equal 'master', sut.card.brand
    assert_equal 12, sut.card.card_expiry.month
    assert_equal 2050, sut.card.card_expiry.year
    assert_equal 'US', sut.billing_address.country
    assert_equal '10014', sut.billing_address.zip
  end

  def test_single_use_token_with_verification
    result = VCR.use_cassette('customer_vault_api/single_use_token_with_verification') do
      sut = sut_client.customer_vault.create_single_use_token(
        card: {
          card_num: '5200400000000009',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: '123',
          billing_address: {
            street: 'U', # trigger AVS not processed for verification response
            country: 'US',
            zip: '10014'
          }
        }
      )

      assert_match UUID_REGEX, sut.id
      assert_match TOKEN_REGEX, sut.payment_token

      authenticated_client.card_payments.create_verification(
        merchant_ref_num: random_id,
        card: {
          paymentToken: sut.payment_token
        }
      )
    end

    assert_match UUID_REGEX, result.id
    assert_match UUID_REGEX, result.merchant_ref_num
    assert_equal 'MC', result.card.type
    assert_equal 'master', result.card.brand
    assert_equal '0009', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal 2050, result.card.card_expiry.year
    assert_equal 'COMPLETED', result.status
    assert Time.parse(result.txn_time)
    assert_match AUTH_CODE_REGEX, result.auth_code
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'NOT_PROCESSED', result.avs_response
    assert result.avs_not_processed?
    assert_equal 'MATCH', result.cvv_verification
    assert result.cvv_match?
  end

  def test_single_use_token_with_verification_and_address_override
    result = VCR.use_cassette('customer_vault_api/single_use_token_with_verification_and_address') do
      sut = sut_client.customer_vault.create_single_use_token(
        card: {
          card_num: '5200400000000009',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: '123'
        }
      )

      assert_match UUID_REGEX, sut.id
      assert_match TOKEN_REGEX, sut.payment_token

      authenticated_client.card_payments.create_verification(
        merchant_ref_num: random_id,
        card: {
          paymentToken: sut.payment_token
        },
        billing_details: {
          country: 'US',
          zip: '10014'
        }
      )
    end

    assert_match UUID_REGEX, result.id
    assert_match UUID_REGEX, result.merchant_ref_num
    assert_equal 'MC', result.card.type
    assert_equal 'master', result.card.brand
    assert_equal '0009', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal 2050, result.card.card_expiry.year
    assert_equal 'COMPLETED', result.status
    assert Time.parse(result.txn_time)
    assert_match AUTH_CODE_REGEX, result.auth_code
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'MATCH', result.avs_response
    assert result.avs_match?
    assert_equal 'MATCH', result.cvv_verification
    assert result.cvv_match?
  end

  def test_single_use_token_with_profile_creation
    profile = VCR.use_cassette('customer_vault_api/single_use_token_with_profile_creation') do
      sut = sut_client.customer_vault.create_single_use_token(
        card: {
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: 123,
          billing_address: {
            country: 'US',
            zip: '10014'
          }
        }
      )

      assert_match UUID_REGEX, sut.id
      assert_match TOKEN_REGEX, sut.payment_token

      create_test_profile(card: { single_use_token: sut.payment_token })
    end

    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_match TOKEN_REGEX, profile.payment_token
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale

    address = profile.addresses.first
    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status

    card = profile.cards.first
    assert_match UUID_REGEX, card.id
    assert_match UUID_REGEX, card.billing_address_id
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
  end

  def test_single_use_token_with_card_creation_for_existing_profile
    card = VCR.use_cassette('customer_vault_api/single_use_token_with_card_creation') do
      sut = sut_client.customer_vault.create_single_use_token(
        card: {
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          },
          cvv: '123',
          billing_address: {
            country: 'US',
            zip: '10014'
          }
        }
      )

      assert_match UUID_REGEX, sut.id
      assert_match TOKEN_REGEX, sut.payment_token

      profile = create_test_profile
      authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        single_use_token: sut.payment_token
      )
    end

    assert_match UUID_REGEX, card.id
    assert_match UUID_REGEX, card.billing_address_id
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
  end

end
