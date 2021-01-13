module Paysafe
  module REST
    class Client
      extend Forwardable

      delegate [:account_number, :api_base, :api_key, :api_secret, :test_mode, :timeout] => :@config

      # Initializes a new Client object
      #
      # @param options [Hash]
      # @return [Paysafe::REST::Client]
      def initialize(**options)
        @config = Configuration.new(**options)
      end

      # @return [Hash]
      def credentials
        { api_key: api_key, api_secret: api_secret }
      end

      # @return [Boolean]
      def credentials?
        credentials.values.all?
      end

      def customer_vault
        @customer_vault ||= Api::CustomerVaultApi.new(@config)
      end

      def card_payments
        @card_payments ||= Api::CardPaymentsApi.new(@config)
      end

      def payments
        @payments ||= Api::PaymentsApi.new(@config)
      end
    end
  end
end
