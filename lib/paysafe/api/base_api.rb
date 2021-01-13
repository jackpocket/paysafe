module Paysafe
  module Api
    class BaseApi
      HEADERS = {
        'Content-Type' => 'application/json',
        'User-Agent' => "PaysafeRubyGem/#{Paysafe::VERSION}",
        'X-Ruby-Version' => RUBY_VERSION,
        'X-Ruby-Platform' => RUBY_PLATFORM
      }

      using Refinements::CamelCase
      using Refinements::SnakeCase

      def initialize(config)
        @config = config
      end

      protected

      # Needed for some API URLs
      def account_number
        @config.account_number
      end

      def http_client
        HTTP
          .headers(HEADERS)
          .timeout(@config.timeout || :null)
          .basic_auth(user: @config.api_key, pass: @config.api_secret)
      end

      def perform_post_with_object(path, data, klass)
        response = http_client.post("#{@config.api_base}#{path}", json: data.to_camel_case)
        process_response(response, klass)
      end

      def perform_get_with_object(path, klass)
        response = http_client.get("#{@config.api_base}#{path}")
        process_response(response, klass)
      end

      def perform_delete(path)
        response = http_client.delete("#{@config.api_base}#{path}")
        process_response(response)
      end

      def perform_put_with_object(path, data, klass)
        response = http_client.put("#{@config.api_base}#{path}", json: data.to_camel_case)
        process_response(response, klass)
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
