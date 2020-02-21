module Paysafe
  module REST
    class Client
      extend Forwardable

      delegate [:account_number, :api_base, :api_key, :api_secret, :test_mode, :timeouts] => :@config

      # Initializes a new Client object
      #
      # @param options [Hash]
      # @return [Paysafe::REST::Client]
      def initialize(options={})
        @config = Configuration.new(options)
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

      def create_single_use_token(data)
        customer_vault.create_single_use_token(data)
      end

      def create_profile_from_token(data)
        customer_vault.create_profile(**data)
      end

      def create_profile(merchant_customer_id:, locale:, **args)
        customer_vault.create_profile(merchant_customer_id: merchant_customer_id, locale: locale, **args)
      end

      def delete_profile(id:)
        customer_vault.delete_profile(id: id)
      end

      def get_profile(id:, fields: [])
        customer_vault.get_profile(id: id, fields: fields)
      end

      def update_profile(id:, merchant_customer_id:, locale:, **args)
        customer_vault.update_profile(id: id, merchant_customer_id: merchant_customer_id, locale: locale, **args)
      end

      def create_address(profile_id:, country:, zip:, **args)
        customer_vault.create_address(profile_id: profile_id, country: country, zip: zip, **args)
      end

      def get_address(profile_id:, id:)
        customer_vault.get_address(profile_id: profile_id, id: id)
      end

      def create_card_from_token(profile_id:, token:)
        customer_vault.create_card(profile_id: profile_id, single_use_token: token)
      end

      def create_card(profile_id:, **data)
        customer_vault.create_card(profile_id: profile_id, **data)
      end

      def delete_card(profile_id:, id:)
        customer_vault.delete_card(profile_id: profile_id, id: id)
      end

      def get_card(profile_id:, id:)
        customer_vault.get_card(profile_id: profile_id, id: id)
      end

      def update_card(profile_id:, id:, month:, year:, **args)
        data = args.merge({
          card_expiry: {
            month: month,
            year: year
          }
        }).reject { |key, value| value.nil? }

        customer_vault.update_card(profile_id: profile_id, id: id, **data)
      end

      def purchase(amount:, token:, merchant_ref_num:, **args)
        data = args.merge({
          amount: amount,
          merchant_ref_num: merchant_ref_num,
          settle_with_auth: true,
          card: {
            payment_token: token
          }
        })
        card_payments.create_authorization(**data)
      end

      def create_verification_from_token(merchant_ref_num:, token:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          card: {
            payment_token: token
          }
        })

        card_payments.create_verification(**data)
      end

    end
  end
end
