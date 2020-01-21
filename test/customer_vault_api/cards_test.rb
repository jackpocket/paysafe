require 'test_helper'

class CustomerVaultApiCardsTest < Minitest::Test

  def setup
    turn_on_vcr!
  end

  def teardown
    turn_off_vcr!
  end

  def test_create_card_with_address_id
    card = VCR.use_cassette('customer_vault_api/create_card_with_address_id') do
      profile = create_test_profile

      address = authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )

      authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: 2050
        },
        billing_address_id: address.id
      )
    end

    assert_match UUID_REGEX, card.id
    assert_match UUID_REGEX, card.billing_address_id
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status
  end

  def test_create_card_without_address_link
    card = VCR.use_cassette('customer_vault_api/create_card_without_address_link') do
      profile = create_test_profile
      authenticated_client.customer_vault.create_card(
        profile_id: profile.id,
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: 2050
        }
      )
    end

    assert_match UUID_REGEX, card.id
    assert_nil card.billing_address_id
    refute card.billing_address_id?
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status
  end

  def test_create_card_failed_400
    error = assert_raises(Paysafe::Error::BadRequest) do
      VCR.use_cassette('customer_vault_api/create_card_failed_bad_request') do
        profile = create_test_profile
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          }
        )
      end
    end

    assert_equal "5068", error.code
    assert_equal 'Either you submitted a request that is missing a mandatory field or the value of a field does not match the format expected.', error.message
    assert error.response[:error][:field_errors].any?
  end

  def test_create_card_failed_409
    error = assert_raises(Paysafe::Error::Conflict) do
      VCR.use_cassette('customer_vault_api/create_card_failed_conflict') do
        profile = create_test_profile
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          }
        )

        # Should fail since card already exists
        authenticated_client.customer_vault.create_card(
          profile_id: profile.id,
          card_num: '4111111111111111',
          card_expiry: {
            month: 12,
            year: 2050
          }
        )
      end
    end

    assert_equal "7503", error.code
    assert_match(/Card number already in use -/, error.message)
  end

  def test_delete_card
    VCR.use_cassette('customer_vault_api/delete_card') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      authenticated_client.customer_vault.delete_card(profile_id: profile.id, id: card.id)
    end
  end

  def test_get_card
    card = VCR.use_cassette('customer_vault_api/get_card') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      authenticated_client.customer_vault.get_card(profile_id: profile.id, id: card.id)
    end

    assert_match UUID_REGEX, card.id
    assert_match UUID_REGEX, card.billing_address_id
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal 2050, card.card_expiry.year
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status
  end

  def test_update_card
    card = VCR.use_cassette('customer_vault_api/update_card') do
      profile = create_test_profile_with_card_and_address
      card = profile.cards.first

      assert_match UUID_REGEX, card.billing_address_id
      assert_equal 12, card.card_expiry.month
      assert_equal 2050, card.card_expiry.year

      authenticated_client.customer_vault.update_card(
        profile_id: profile.id,
        id: card.id,
        card_expiry: {
          month: 6,
          year: 2055
        }
      )
    end

    assert_match UUID_REGEX, card.id
    assert_nil card.billing_address_id
    refute card.billing_address_id?
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 6, card.card_expiry.month
    assert_equal 2055, card.card_expiry.year
    assert_match TOKEN_REGEX, card.payment_token
    assert_equal 'ACTIVE', card.status
  end

end
