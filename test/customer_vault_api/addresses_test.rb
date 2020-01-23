require 'test_helper'

class CustomerVaultApiAddressesTest < Minitest::Test

  def test_create_address
    result = VCR.use_cassette('customer_vault_api/create_address') do
      profile = create_test_profile
      authenticated_client.customer_vault.create_address(
        profile_id: profile.id,
        country: 'US',
        zip: '10014'
      )
    end

    assert_match UUID_REGEX, result.id
    assert_equal 'US', result.country
    assert_equal '10014', result.zip
    assert_equal 'ACTIVE', result.status
  end

  def test_delete_address
    VCR.use_cassette('customer_vault_api/delete_address') do
      profile = create_test_profile_with_card_and_address
      address = profile.addresses.first

      authenticated_client.customer_vault.delete_address(
        profile_id: profile.id,
        id: address.id
      )
    end
  end

  def test_get_address
    address = VCR.use_cassette('customer_vault_api/get_address') do
      profile = create_test_profile_with_card_and_address
      address = profile.addresses.first

      authenticated_client.customer_vault.get_address(profile_id: profile.id, id: address.id)
    end

    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10014', address.zip
    assert_equal 'ACTIVE', address.status
  end

  def test_update_address
    address = VCR.use_cassette('customer_vault_api/update_address') do
      profile = create_test_profile_with_card_and_address
      address = profile.addresses.first

      assert_equal '10014', address.zip

      authenticated_client.customer_vault.update_address(
        profile_id: profile.id,
        id: address.id,
        country: 'US',
        zip: '10018'
      )
    end

    assert_match UUID_REGEX, address.id
    assert_equal 'US', address.country
    assert_equal '10018', address.zip
    assert_equal 'ACTIVE', address.status
  end

end
