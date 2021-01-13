module Paysafe
  class Configuration

    API_TEST = 'https://api.test.paysafe.com'
    API_LIVE = 'https://api.paysafe.com'

    attr_reader :account_number, :api_base, :api_key, :api_secret, :test_mode, :timeout

    def initialize(**options)
      @test_mode = true

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      @api_base = test_mode ? API_TEST : API_LIVE
    end

  end
end
