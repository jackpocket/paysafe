module Paysafe
  class Result

    # @return [Hash]
    attr_reader :attributes

    class << self
      # Define methods that retrieve the value from attributes
      #
      # @param attrs [Array, Symbol]
      def generate_attr_reader(*attrs)
        attrs.each do |attr|
          define_attribute_method(attr)
          define_predicate_method(attr)
        end
      end

      def generate_predicate_attr_reader(*attrs)
        attrs.each do |attr|
          define_predicate_method(attr)
        end
      end

      # Dynamically define a method for an attribute
      #
      # @param key1 [Symbol]
      def define_attribute_method(key1)
        define_method(key1) do
          if instance_variable_defined? "@#{key1}"
            return instance_variable_get("@#{key1}")
          end

          instance_variable_set("@#{key1}", get_value_by(key1))
        end
      end

      # Dynamically define a predicate method for an attribute
      #
      # @param key1 [Symbol]
      # @param key2 [Symbol]
      def define_predicate_method(key1, key2 = key1)
        define_method(:"#{key1}?") do
          !attr_falsey_or_empty?(key2)
        end
      end
    end

    # Initializes a new object
    #
    # @param attributes [Hash]
    # @return [Paysafe::Result]
    def initialize(attributes={})
      @attributes = attributes || {}

      @attributes.each do |key, value|
        Result.generate_attr_reader key
      end
    end

    def empty?
      @attributes.empty?
    end

    private

    def attr_falsey_or_empty?(key)
      !@attributes[key] || @attributes[key].respond_to?(:empty?) && @attributes[key].empty?
    end

    def get_value_by(key)
      case @attributes[key]
      when Hash
        Result.new(@attributes[key])
      when Array
        @attributes[key].map { |value| Result.new(value) }
      else
        @attributes[key]
      end
    end

  end
end
