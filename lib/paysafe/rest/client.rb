require 'http'
require 'json'

module Paysafe
  module REST
    class Client

      API_TEST = 'https://api.test.paysafe.com'
      API_LIVE = 'https://api.paysafe.com'

      HEADERS = {
        'Content-Type'    => 'application/json',
        'User-Agent'      => "PaysafeRubyGem/#{Paysafe::VERSION}",
        'X-Ruby-Version'  => RUBY_VERSION,
        'X-Ruby-Platform' => RUBY_PLATFORM
      }

      using Refinements::CamelCase
      using Refinements::SnakeCase

      attr_accessor :account_number, :api_key, :api_secret, :test_mode, :timeouts
      attr_reader :api_base

      # Initializes a new Client object
      #
      # @param options [Hash]
      # @return [Paysafe::REST::Client]
      def initialize(options={})
        @test_mode = true

        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end

        yield(self) if block_given?

        @api_base = test_mode ? API_TEST : API_LIVE
      end

      # @return [Hash]
      def credentials
        { api_key: api_key, api_secret: api_secret }
      end

      # @return [Boolean]
      def credentials?
        credentials.values.all?
      end

      def create_single_use_token(data)
        response = post(path: "/customervault/v1/singleusetokens", data: data.to_camel_case)
        process_response(response, SingleUseToken)
      end

      def create_profile_from_token(data)
        response = post(path: "/customervault/v1/profiles", data: data.to_camel_case)
        process_response(response, Profile)
      end

      def create_profile(merchant_customer_id:, locale:, **args)
        data = args.merge({
          merchant_customer_id: merchant_customer_id,
          locale: locale
        }).to_camel_case

        response = post(path: "/customervault/v1/profiles", data: data)
        process_response(response, Profile)
      end

      def delete_profile(id:)
        response = delete(path: "/customervault/v1/profiles/#{id}")
        process_response(response)
      end

      def get_profile(id:, fields: [])
        path = "/customervault/v1/profiles/#{id}"
        path += "?fields=#{fields.join(',')}" if !fields.empty?

        response = get(path: path)
        process_response(response, Profile)
      end

      def update_profile(id:, merchant_customer_id:, locale:, **args)
        data = args.merge({
          merchant_customer_id: merchant_customer_id,
          locale: locale
        }).to_camel_case

        response = put(path: "/customervault/v1/profiles/#{id}", data: data)
        process_response(response, Profile)
      end

      def create_address(profile_id:, country:, zip:, **args)
        data = args.merge({ country: country, zip: zip }).to_camel_case
        response = post(path: "/customervault/v1/profiles/#{profile_id}/addresses", data: data)
        process_response(response, Address)
      end

      def get_address(profile_id:, id:)
        response = get(path: "/customervault/v1/profiles/#{profile_id}/addresses/#{id}")
        process_response(response, Address)
      end

      def create_card_from_token(profile_id:, token:)
        data = { single_use_token: token }.to_camel_case
        response = post(path: "/customervault/v1/profiles/#{profile_id}/cards", data: data)
        process_response(response, Card)
      end

      def create_card(profile_id:, number:, month:, year:, **args)
        data = args.merge({
          card_num: number,
          card_expiry: {
            month: month,
            year: year
          }
        }).reject { |key, value| value.nil? }.to_camel_case

        response = post(path: "/customervault/v1/profiles/#{profile_id}/cards", data: data)
        process_response(response, Card)
      end

      def delete_card(profile_id:, id:)
        response = delete(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}")
        process_response(response)
      end

      def get_card(profile_id:, id:)
        response = get(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}")
        process_response(response, Card)
      end

      def update_card(profile_id:, id:, month:, year:, **args)
        data = args.merge({
          card_expiry: {
            month: month,
            year: year
          }
        }).reject { |key, value| value.nil? }.to_camel_case

        response = put(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}", data: data)
        process_response(response, Card)
      end

      def purchase(amount:, token:, merchant_ref_num:, **args)
        data = args.merge({
          amount: amount,
          merchant_ref_num: merchant_ref_num,
          settle_with_auth: true,
          card: {
            payment_token: token
          }
        }).to_camel_case

        response = post(path: "/cardpayments/v1/accounts/#{account_number}/auths", data: data)
        process_response(response, Authorization)
      end

      def create_verification_from_token(merchant_ref_num:, token:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          card: {
            payment_token: token
          }
        }).to_camel_case

        response = post(path: "/cardpayments/v1/accounts/#{account_number}/verifications", data: data)
        process_response(response, Verification)
      end

      def verify_card(merchant_ref_num:, number:, month:, year:, cvv:, address:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          billing_details: address,
          card: {
            card_num: number,
            cvv: cvv,
            card_expiry: {
              month: month,
              year: year
            }
          }
        }).to_camel_case

        response = post(path: "/cardpayments/v1/accounts/#{account_number}/verifications", data: data)
        process_response(response, Verification)
      end

      def get_transaction(transaction_id: nil, merchant_ref_num: nil)
        response =
          if transaction_id.nil?
            get(path: "/cardpayments/v1/accounts/#{account_number}/auths/?merchantRefNum=#{merchant_ref_num}")
          else
            get(path: "/cardpayments/v1/accounts/#{account_number}/auths/#{transaction_id}")
          end

         process_response(response, Authorization)
      end

      private

      def http_client
        HTTP
          .headers(HEADERS)
          .timeout(timeouts ? timeouts : :null)
          .basic_auth(user: api_key, pass: api_secret)
      end

      def post(path:, data:)
        http_client.post("#{api_base}#{path}", json: data)
      end

      def get(path:)
        http_client.get("#{api_base}#{path}")
      end

      def delete(path:)
        http_client.delete("#{api_base}#{path}")
      end

      def put(path:, data:)
        http_client.put("#{api_base}#{path}", json: data)
      end

      def process_response(response, klass=nil)
        data = parse_response_body(response.to_s)

        if response.status.success?
          klass&.new(data)
        else
          fail Error.from_response(data, response.code)
        end
      end

      def parse_response_body(body)
        return nil if body.strip.empty?
        JSON.parse(body, symbolize_names: true)&.to_snake_case
      rescue JSON::ParserError
      end

    end
  end
end
