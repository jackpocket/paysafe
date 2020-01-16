require 'test_helper'

class SingleUseTokenTest < Minitest::Test

  def setup
    skip if ENV['SKIP_INTEGRATION'] == 'true' || ENV['PAYSAFE_SUT_API_KEY'].nil?
    turn_off_vcr!

    @sut_client = authenticated_sut_client
    @year = 2050
  end

  def test_single_use_token_with_verification_request
    sut = @sut_client.create_single_use_token(
      card: {
        card_num: '5200400000000009',
        card_expiry: {
          month: 12,
          year: @year
        },
        cvv: '123',
        billing_address: {
          street: 'U', # trigger AVS NOT_PROCESSED response
          country: 'US',
          zip: '10014'
        }
      }
    )

    refute_predicate sut.id, :empty?
    refute_predicate sut.payment_token, :empty?
    assert_equal '520040', sut.card.card_bin
    assert_equal '0009', sut.card.last_digits
    assert_equal 'MC', sut.card.card_type
    assert_equal 'master', sut.card.brand
    assert_equal 12, sut.card.card_expiry.month
    assert_equal @year, sut.card.card_expiry.year
    assert_equal 'US', sut.billing_address.country
    assert_equal '10014', sut.billing_address.zip

    single_use_token = sut.payment_token

    id = Time.now.to_f.to_s
    result = authenticated_client.create_verification_from_token(merchant_ref_num: id, token: single_use_token)

    refute_predicate result.id, :empty?
    assert_equal id, result.merchant_ref_num
    refute_predicate result.txn_time, :empty?
    assert_equal 'COMPLETED', result.status
    assert_equal 'MC', result.card.type
    assert_equal 'master', result.card.brand
    assert_equal '0009', result.card.last_digits
    assert_equal 12, result.card.card_expiry.month
    assert_equal @year, result.card.card_expiry.year
    refute_predicate result.auth_code, :empty?
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'NOT_PROCESSED', result.avs_response
    assert result.avs_not_processed?
    assert_equal 'MATCH', result.cvv_verification
    assert result.cvv_match?
  end

  def test_single_use_token_and_redeem_with_create_profile
    sut = @sut_client.create_single_use_token(
      card: {
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: @year
        },
        cvv: 123,
        billing_address: {
          country: 'US',
          zip: '10014'
        }
      }
    )

    refute_predicate sut.id, :empty?
    refute_predicate sut.payment_token, :empty?
    assert_equal '411111', sut.card.card_bin
    assert_equal '1111', sut.card.last_digits
    assert_equal 'VI', sut.card.card_type
    assert_equal 'visa', sut.card.brand
    assert_equal 12, sut.card.card_expiry.month
    assert_equal @year, sut.card.card_expiry.year
    assert_equal 'US', sut.billing_address.country
    assert_equal '10014', sut.billing_address.zip

    id = Time.now.to_f.to_s
    profile = authenticated_client.create_profile_from_token(
      merchant_customer_id: id,
      locale: 'en_US',
      first_name: 'test',
      last_name: 'test',
      email: 'test@test.com',
      card: {
        single_use_token: sut.payment_token,
      }
    )

    assert_equal id, profile.merchant_customer_id
    assert_equal 'en_US', profile.locale
    assert_equal 'test', profile.first_name
    assert_equal 'test', profile.last_name
    assert_equal 'test@test.com', profile.email
    assert_equal 'ACTIVE', profile.status
    refute_predicate profile.payment_token, :empty?

    address = profile.addresses.first
    refute_predicate address.id, :empty?
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status

    card = profile.cards.first
    refute_predicate card.id, :empty?
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal @year, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
    refute_predicate card.billing_address_id, :empty?
  end

  def test_redeem_sut_with_create_card
    sut = @sut_client.create_single_use_token(
      card: {
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: @year
        },
        cvv: '123',
        billing_address: {
          country: 'US',
          zip: '10014'
        }
      }
    )

    refute_predicate sut.id, :empty?
    refute_predicate sut.payment_token, :empty?
    assert_equal 'VI', sut.card.card_type
    assert_equal 'visa', sut.card.brand
    assert_equal '411111', sut.card.card_bin
    assert_equal '1111', sut.card.last_digits
    assert_equal 12, sut.card.card_expiry.month
    assert_equal @year, sut.card.card_expiry.year
    assert_equal 'US', sut.billing_address.country
    assert_equal '10014', sut.billing_address.zip

    profile = authenticated_client.create_profile(
      merchant_customer_id: Time.now.to_f.to_s,
      locale: 'en_US'
    )

    card = authenticated_client.create_card_from_token(
      profile_id: profile.id,
      token: sut.payment_token
    )

    refute_predicate card.id, :empty?
    refute_predicate card.payment_token, :empty?
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal @year, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
    assert card.billing_address_id?

    address = authenticated_client.create_address(
      profile_id: profile.id,
      country: 'US',
      zip: '10014'
    )
    card = authenticated_client.update_card(
      profile_id: profile.id,
      id: card.id,
      year: card.card_expiry.year,
      month: card.card_expiry.month,
      billing_address_id: address.id,
    )

    refute_predicate card.id, :empty?
    refute_predicate card.payment_token, :empty?
    assert_equal '411111', card.card_bin
    assert_equal '1111', card.last_digits
    assert_equal 'VI', card.card_type
    assert_equal 'visa', card.brand
    assert_equal 12, card.card_expiry.month
    assert_equal @year, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
    assert card.billing_address_id?
    assert_equal address.id, card.billing_address_id
  end

end
