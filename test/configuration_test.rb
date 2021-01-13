require 'test_helper'

class ConfigurationTest < Minitest::Test

  def test_defaults
    config = Paysafe::Configuration.new
    assert_equal config.test_mode, true
    assert_equal config.api_base, Paysafe::Configuration::API_TEST
  end

  def test_options_are_set
    config = Paysafe::Configuration.new(
      account_number: 'account_number',
      api_key: 'api_key',
      api_secret: 'api_secret',
      test_mode: false,
      timeout: 30
    )

    assert_equal config.account_number, 'account_number'
    assert_equal config.api_key, 'api_key'
    assert_equal config.api_secret, 'api_secret'
    assert_equal config.test_mode, false
    assert_equal config.timeout, 30
  end

  def test_api_base_changes_based_on_test_mode
    config = Paysafe::Configuration.new(test_mode: false)
    assert_equal config.test_mode, false
    assert_equal config.api_base, Paysafe::Configuration::API_LIVE
  end

end
