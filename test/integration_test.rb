require 'test_helper'

class IntegrationTest < Minitest::Test

  def setup
    skip if ENV['SKIP_INTEGRATION'] == 'true'
    turn_off_vcr!

    @profile = authenticated_client.create_profile(
      merchant_customer_id: Time.now.to_f.to_s,
      locale: 'en_US',
      first_name: 'test',
      last_name: 'test',
      email: 'test@test.com'
    )
  end

  def teardown
    authenticated_client.delete_profile(id: @profile.id)
    @profile = nil
  end

  def test_invalid_credentials
    client = Paysafe::REST::Client.new
    assert_raises(Paysafe::Error::Unauthorized) {
      client.get_profile(id: @profile.id)
    }
  end

  def test_verification
    id = Time.now.to_f.to_s

    result = authenticated_client.verify_card(
      merchant_ref_num: id,
      number: '5410110488911728',
      month: 6,
      year: 2019,
      cvv: 123,
      address: {
        street: 'Z', # trigger AVS MATCH_ZIP_ONLY response
        country: 'US',
        zip: '10014'
      }
    )

    refute_predicate result.id, :empty?
    assert_equal id, result.merchant_ref_num
    refute_predicate result.txn_time, :empty?
    assert_equal 'COMPLETED', result.status
    assert_equal 'MC', result.card.type
    assert_equal '1728', result.card.last_digits
    assert_equal 6, result.card.card_expiry.month
    assert_equal 2019, result.card.card_expiry.year
    refute_predicate result.auth_code, :empty?
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'MATCH_ZIP_ONLY', result.avs_response
    assert_equal 'MATCH', result.cvv_verification
  end

  def test_creating_profile_with_card_and_address
    id = Time.now.to_f.to_s

    profile = authenticated_client.create_profile(
      merchant_customer_id: id,
      locale: 'en_US',
      first_name: 'test',
      last_name: 'test',
      email: 'test@test.com',
      card: {
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: 2019
        },
        billing_address: {
          country: 'US', zip: '10014'
        }
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
    assert_equal 12, card.card_expiry.month
    assert_equal 2019, card.card_expiry.year
    assert_equal 'ACTIVE', card.status
    refute_predicate card.billing_address_id, :empty?

    profile = authenticated_client.update_profile(
      id: profile.id,
      merchant_customer_id: id,
      locale: 'en_US',
      first_name: 'Testing',
      last_name: 'Testing',
      email: 'example@test.com'
    )

    assert_equal id, profile.merchant_customer_id
    assert_equal 'en_US', profile.locale
    assert_equal 'Testing', profile.first_name
    assert_equal 'Testing', profile.last_name
    assert_equal 'example@test.com', profile.email
    assert_equal 'ACTIVE', profile.status
    refute_predicate profile.payment_token, :empty?

    authenticated_client.delete_profile(id: profile.id)
  end

  def test_creating_profile_with_card_fails_then_succeeds
    id = Time.now.to_f.to_s

    assert_raises(Paysafe::Error::BadRequest) do
      profile = authenticated_client.create_profile(
        merchant_customer_id: id,
        locale: 'en_US',
        first_name: 'test',
        last_name: 'test',
        email: 'test@test.com',
        card: {
          card_num: '4111111',
          card_expiry: {
            month: 12,
            year: 2019
          },
          billing_address: {
            country: 'US', zip: '10014'
          }
        }
      )
    end

    profile = authenticated_client.create_profile(
      merchant_customer_id: id,
      locale: 'en_US',
      first_name: 'test',
      last_name: 'test',
      email: 'test@test.com',
      card: {
        card_num: '4111111111111111',
        card_expiry: {
          month: 12,
          year: 2019
        },
        billing_address: {
          country: 'US', zip: '10014'
        }
      }
    )

    refute_predicate profile.id, :empty?
    assert_equal 'ACTIVE', profile.status

    card = profile.cards.first
    refute_predicate card.id, :empty?

    authenticated_client.delete_profile(id: profile.id)
  end

  def test_getting_profile_with_card_and_address
    id = Time.now.to_f.to_s

    # 1 - Create Address and attach to Profile
    @address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')

    # 2 - Create Card and attach to Profile
    @card = authenticated_client.create_card(profile_id: @profile.id, number: '4111111111111111', month: 12, year: 2019, billing_address_id: @address.id)

    # 3 - Retrieve Profile with Cards and Addresses
    profile = authenticated_client.get_profile(id: @profile.id, fields: [:cards,:addresses])

    assert_equal @profile.id, profile.id
    assert_equal @profile.status, profile.status
    assert_equal @profile.locale, profile.locale
    assert_equal @profile.first_name, profile.first_name
    assert_equal @profile.last_name, profile.last_name
    assert_equal @profile.email, profile.email
    assert_equal @profile.merchant_customer_id, profile.merchant_customer_id

    card = profile.cards.first
    assert_equal @card.id, card.id
    assert_equal @card.status, card.status
    assert_equal @card.card_type, card.card_type
    assert_equal @card.last_digits, card.last_digits
    assert_equal @card.card_bin, card.card_bin
    assert_equal @card.card_expiry.month, card.card_expiry.month
    assert_equal @card.card_expiry.year, card.card_expiry.year
    assert_equal @card.billing_address_id, card.billing_address_id
    assert_equal @card.payment_token, card.payment_token

    address = profile.addresses.first
    assert_equal @address.id, address.id
    assert_equal @address.status, address.status
    assert_equal @address.country, address.country
    assert_equal @address.zip, address.zip
  end

  def test_creating_a_card_with_verification
    id = Time.now.to_f.to_s

    # 1 - Verify Card
    result = authenticated_client.verify_card(
      merchant_ref_num: id,
      number: '5410110488911728',
      month: 6,
      year: 2019,
      cvv: 123,
      address: {
        street: 'Z', # trigger AVS MATCH_ZIP_ONLY response
        country: 'US',
        zip: '10014'
      }
    )

    refute_predicate result.id, :empty?
    assert_equal id, result.merchant_ref_num
    refute_predicate result.txn_time, :empty?
    assert_equal 'COMPLETED', result.status
    assert_equal 'MC', result.card.type
    assert_equal '1728', result.card.last_digits
    assert_equal 6, result.card.card_expiry.month
    assert_equal 2019, result.card.card_expiry.year
    refute_predicate result.auth_code, :empty?
    assert_equal 'US', result.billing_details.country
    assert_equal '10014', result.billing_details.zip
    assert_equal 'USD', result.currency_code
    assert_equal 'MATCH_ZIP_ONLY', result.avs_response
    assert_equal 'MATCH', result.cvv_verification

    # 2 - Create Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')

    # 3 - Create Card and attach to Profile
    card = authenticated_client.create_card(profile_id: @profile.id, number: '5410110488911728', month: 6, year: 2019, billing_address_id: address.id)

    assert_equal 'MC', card.card_type
    assert_equal 6, card.card_expiry.month
    assert_equal 2019, card.card_expiry.year
    assert_equal address.id, card.billing_address_id
    assert_equal 'ACTIVE', card.status
  end

  def test_deleting_a_card
    # 1 - Create Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')

    # 2 - Create Card and attach to Profile
    card = authenticated_client.create_card(profile_id: @profile.id, number: '5410110488911728', month: 12, year: 2019, billing_address_id: address.id)

    # 3 - Delete Card
    authenticated_client.delete_card(profile_id: @profile.id, id: card.id)

    # 4 - Deleting an already deleted card fails
    assert_raises(Paysafe::Error::NotFound) {
      authenticated_client.delete_card(profile_id: @profile.id, id: card.id)
    }
  end

  def test_invalid_card_number
    assert_raises(Paysafe::Error::BadRequest) {
      authenticated_client.create_card(profile_id: @profile.id, number: '4111111111', month: 12, year: 2017)
    }
  end

  def test_updating_a_card
    # 1 - Create Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')
    address_id = address.id

    # 2 - Create Card and attach to Profile
    card = authenticated_client.create_card(profile_id: @profile.id, number: '5410110488911728', month: 12, year: 2017, billing_address_id: address_id, holder_name: 'John Smith')

    # 3 - Update Card
    card = authenticated_client.update_card(profile_id: @profile.id, id: card.id, month: 6, year: 2019, billing_address_id: address_id, holder_name: 'Johnny Smith')

    assert_equal 'MC', card.card_type
    assert_equal 6, card.card_expiry.month
    assert_equal 2019, card.card_expiry.year
    assert_equal address_id, card.billing_address_id
    assert_equal 'Johnny Smith', card.holder_name
    assert_equal 'ACTIVE', card.status
  end

  def test_creating_an_address
    # 1 - Create Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')
    first_address_id = address.id

    # 2 - Create duplicate Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')
    second_address_id = address.id

    refute_equal first_address_id, second_address_id
  end

  def test_full_purchase_flow
    # 1 - Create Address and attach to Profile
    address = authenticated_client.create_address(profile_id: @profile.id, country: 'US', zip: '10014')
    address_id = address.id

    # 2 - Create Card and attach to Profile
    card = authenticated_client.create_card(profile_id: @profile.id, number: '5410110488911728', month: 12, year: 2019, billing_address_id: address_id)

    refute_predicate card.id, :empty?
    assert_equal '541011', card.card_bin
    assert_equal '1728', card.last_digits
    assert_equal 12, card.card_expiry.month
    assert_equal 2019, card.card_expiry.year
    assert_equal 'MC', card.card_type
    assert_equal 'ACTIVE', card.status
    refute_predicate card.payment_token, :empty?

    # 3 - Make a Purchase with Card
    id = Time.now.to_i.to_s
    result = authenticated_client.purchase(amount: 400, token: card.payment_token, merchant_ref_num: id)

    refute_predicate result.id, :empty?
    assert_equal 400, result.amount
    assert_equal true, result.settle_with_auth
    assert_equal id, result.merchant_ref_num
    refute_predicate result.txn_time, :empty?
    assert_equal 'COMPLETED', result.status
    assert_equal 'USD', result.currency_code
    assert_equal 'MATCH', result.avs_response
    refute_predicate result.card, :empty?
    refute_predicate result.profile, :empty?
    refute_predicate result.billing_details, :empty?
    refute_predicate result.auth_code, :empty?

    # 4 - Delete Card
    authenticated_client.delete_card(profile_id: @profile.id, id: card.id)
  end

end
