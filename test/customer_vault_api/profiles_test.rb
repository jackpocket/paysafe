require 'test_helper'

class CustomerVaultApiProfilesTest < Minitest::Test

  def test_create_profile
    profile = VCR.use_cassette('customer_vault_api/create_profile') do
      create_test_profile
    end

    assert_match UUID_REGEX, profile.id
    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_match TOKEN_REGEX, profile.payment_token
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale
  end

  def test_create_profile_failed
    error = assert_raises(Paysafe::Error::BadRequest) do
      VCR.use_cassette('customer_vault_api/create_profile_failed') do
        authenticated_client.customer_vault.create_profile(
          merchant_customer_id: '',
          locale: ''
        )
      end
    end

    assert_equal '5068', error.code
    assert_equal 'Either you submitted a request that is missing a mandatory field or the value of a field does not match the format expected. (Code 5068) Field Errors: The `locale` may not be empty. The `merchantCustomerId` may not be empty. The `merchantCustomerId` size must be between 1 and 100.', error.message
  end

  def test_create_profile_with_card_and_address
    profile = VCR.use_cassette('customer_vault_api/create_profile_with_card_and_address') do
      create_test_profile_with_card_and_address
    end

    assert_match UUID_REGEX, profile.id
    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_match TOKEN_REGEX, profile.payment_token
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale

    card = profile.cards.first
    assert_match UUID_REGEX, card.id
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match UUID_REGEX, card.billing_address_id
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status

    address = profile.addresses.first
    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_delete_profile
    VCR.use_cassette('customer_vault_api/delete_profile') do
      profile_id = create_test_profile.id
      authenticated_client.customer_vault.delete_profile(id: profile_id)
    end
  end

  def test_delete_profile_failed_not_found
    error = assert_raises(Paysafe::Error::NotFound) do
      VCR.use_cassette('customer_vault_api/delete_profile_failed_not_found') do
        authenticated_client.customer_vault.delete_profile(id: 'unknown')
      end
    end

    assert_equal "5269", error.code
    assert_equal "The ID(s) specified in the URL do not correspond to the values in the system.: unknown (Code 5269)", error.message
  end

  def test_get_profile
    profile = VCR.use_cassette('customer_vault_api/get_profile') do
      profile_id = create_test_profile.id
      authenticated_client.customer_vault.get_profile(id: profile_id)
    end

    assert_match UUID_REGEX, profile.id
    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_match TOKEN_REGEX, profile.payment_token
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale
  end

  def test_get_profile_with_fields
    profile = VCR.use_cassette('customer_vault_api/get_profile_with_cards_and_addresses') do
      profile_id = create_test_profile_with_card_and_address.id
      authenticated_client.customer_vault.get_profile(
        id: profile_id,
        fields: [:cards, :addresses]
      )
    end

    assert_match UUID_REGEX, profile.id
    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_match TOKEN_REGEX, profile.payment_token
    assert_equal 'ACTIVE', profile.status
    assert_equal 'en_US', profile.locale

    assert_equal 1, profile.cards.count

    card = profile.cards.first
    assert_match UUID_REGEX, card.id
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match UUID_REGEX, card.billing_address_id
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status

    assert_equal 1, profile.addresses.count

    address = profile.addresses.first
    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_update_profile
    profile = VCR.use_cassette('customer_vault_api/update_profile') do
      profile = create_test_profile
      assert_equal 'test', profile.first_name
      assert_equal 'test', profile.last_name
      assert_equal 'test@test.com', profile.email

      authenticated_client.customer_vault.update_profile(
        id: profile.id,
        merchant_customer_id: random_id,
        locale: 'en_US',
        first_name: 'Testing',
        last_name: 'Testing',
        email: 'example@test.com'
      )
    end

    assert_match UUID_REGEX, profile.merchant_customer_id
    assert_equal 'en_US', profile.locale
    assert_equal 'Testing', profile.first_name
    assert_equal 'Testing', profile.last_name
    assert_equal 'example@test.com', profile.email
    assert_equal 'ACTIVE', profile.status
    assert_match TOKEN_REGEX, profile.payment_token
  end

end
