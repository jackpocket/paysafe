require 'http'

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
        {
          account_number: account_number,
          api_key: api_key,
          api_secret: api_secret
        }
      end

      # @return [Boolean]
      def credentials?
        credentials.values.all?
      end

      def create_single_use_token(data)
        response = post(path: "/customervault/v1/singleusetokens", data: data.to_camel_case)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_profile_from_token(data)
        response = post(path: "/customervault/v1/profiles", data: data.to_camel_case)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_profile(merchant_customer_id:, locale:, **args)
        data = {
          merchantCustomerId: merchant_customer_id,
          locale: locale,
          firstName: args[:first_name],
          lastName: args[:last_name],
          email: args[:email],
          card: args[:card]
        }

        response = post(path: "/customervault/v1/profiles", data: data.to_camel_case)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def delete_profile(id:)
        response = delete(path: "/customervault/v1/profiles/#{id}")
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response.body)
      end

      def get_profile(id:, fields: [])
        path = "/customervault/v1/profiles/#{id}"
        path += "?fields=#{fields.join(',')}" if !fields.empty?

        response = get(path: path)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def update_profile(id:, merchant_customer_id:, locale:, **args)
        data = {
          merchantCustomerId: merchant_customer_id,
          locale: locale,
          firstName: args[:first_name],
          lastName: args[:last_name],
          email: args[:email]
        }

        response = put(path: "/customervault/v1/profiles/#{id}", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_address(profile_id:, country:, zip:, **args)
        data = {
          nickName: args[:nick_name],
          street: args[:street],
          city: args[:city],
          country: country,
          state: args[:state],
          zip: zip
        }

        response = post(path: "/customervault/v1/profiles/#{profile_id}/addresses", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_card_from_token(profile_id, token:)
        data = { singleUseToken: token }
        response = post(path: "/customervault/v1/profiles/#{profile_id}/cards", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_card(profile_id:, number:, month:, year:, **args)
        data = {
          cardNum: number,
          cardExpiry: {
            month: month,
            year: year
          },
          nickName: args[:nick_name],
          holderName: args[:holder_name],
          merchantRefNum: args[:merchant_ref_num],
          billingAddressId: args[:billing_address_id],
          defaultCardIndicator: args[:default_card_indicator]
        }.reject { |key, value| value.nil? }

        response = post(path: "/customervault/v1/profiles/#{profile_id}/cards", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def delete_card(profile_id:, id:)
        response = delete(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}")
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def get_card(profile_id:, id:)
        response = get(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}")
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def update_card(profile_id:, id:, month:, year:, **args)
        data = {
          cardExpiry: {
            month: month,
            year: year
          },
          nickName: args[:nick_name],
          holderName: args[:holder_name],
          merchantRefNum: args[:merchant_ref_num],
          billingAddressId: args[:billing_address_id],
          defaultCardIndicator: args[:default_card_indicator]
        }.reject { |key, value| value.nil? }

        response = put(path: "/customervault/v1/profiles/#{profile_id}/cards/#{id}", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def purchase(amount:, token:, merchant_ref_num:, **args)
        data = {
          amount: amount,
          merchantRefNum: merchant_ref_num,
          settleWithAuth: true,
          card: {
            paymentToken: token
          }
        }

        response = post(path: "/cardpayments/v1/accounts/#{account_number}/auths", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def create_verification_from_token(merchant_ref_num:, token:)
        data = { merchantRefNum: merchant_ref_num, card: { paymentToken: token } }
        response = post(path: "/cardpayments/v1/accounts/#{account_number}/verifications", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      def verify_card(merchant_ref_num:, number:, month:, year:, **args)
        data = {
          merchantRefNum: merchant_ref_num,
          card: {
            cardNum: number,
            cardExpiry: {
              month: month,
              year: year
            },
            cvv: args[:cvv]
          },
          profile: {
            firstName: args[:first_name],
            lastName: args[:last_name],
            email: args[:email]
          },
          billingDetails: args[:address],
          customerIp: args[:customer_ip],
          description: args[:description]
        }

        response = post(path: "/cardpayments/v1/accounts/#{account_number}/verifications", data: data)
        response_body = symbolize_keys!(response.parse)
        fail_or_return_response_body(response.code, response_body)
      end

      private

      def http_client
        HTTP
          .headers(HEADERS)
          .timeout(@timeouts ? @timeouts : :null)
          .basic_auth(user: @api_key, pass: @api_secret)
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

      def symbolize_keys!(object)
        if object.is_a?(Array)
          object.each_with_index do |val, index|
            object[index] = symbolize_keys!(val)
          end
        elsif object.is_a?(Hash)
          object.keys.each do |key|
            object[key.to_sym] = symbolize_keys!(object.delete(key))
          end
        end
        object
      end

      def fail_or_return_response_body(code, body)
        if code < 200 || code >= 206
          error = Paysafe::Error.error_from_response(body, code)
          fail(error)
        end
        Result.new(body&.to_snake_case) if body.is_a? Hash
      end

    end
  end
end
