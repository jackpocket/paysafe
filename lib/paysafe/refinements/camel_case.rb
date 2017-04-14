module Paysafe
  module Refinements
    module CamelCase
      refine Hash do

        def to_camel_case(data = self)
          case data
          when Array
            data.map { |value| to_camel_case(value) }
          when Hash
            data.map { |key, value| [camel_case_key(key), to_camel_case(value)] }.to_h
          else
            data
          end
        end

        private

        def camel_case_key(key)
          case key
          when Symbol
            camel_case(key.to_s).to_sym
          when String
            camel_case(key).to_sym
          else
            key
          end
        end

        def camel_case(string)
          @__memoize_camelcase ||= {}
          return @__memoize_camelcase[string] if @__memoize_camelcase[string]
          @__memoize_camelcase[string] = string.gsub(/(?:_+)([a-z])/) { $1.upcase }
          @__memoize_camelcase[string]
        end

      end
    end
  end
end
