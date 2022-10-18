module Paysafe
  class Result

    class << self
      # Define methods that retrieve the value from attributes
      #
      # @param attrs [Array, Symbol]
      def attributes(*attrs)
        attrs.each do |attr|
          define_attribute_method(attr)
          define_predicate_method(attr)
        end
      end

      # Define object methods from attributes
      #
      # @param klass [Symbol]
      # @param key1 [Symbol]
      def object_attribute(klass, key1)
        define_attribute_method(key1, klass)
        define_predicate_method(key1)
      end

      # Dynamically define a method for an attribute
      #
      # @param key1 [Symbol]
      # @param klass [Symbol]
      def define_attribute_method(key1, klass = nil)
        define_method(key1) do
          if instance_variable_defined?("@#{key1}")
            return instance_variable_get("@#{key1}")
          end
          instance_variable_set("@#{key1}", get_value_by(key1, klass))
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
    end

    # @return [Hash]
    attr_reader :attributes

    # @return [Boolean]
    def empty?
      @attributes.empty?
    end

    private

    def attr_falsey_or_empty?(key)
      !@attributes[key] || @attributes[key].respond_to?(:empty?) && @attributes[key].empty?
    end

    def get_value_by(key, klass = nil)
      return @attributes[key] if klass.nil?

      case @attributes[key]
      when Hash
        Paysafe.const_get(klass).new(@attributes[key])
      when Array
        @attributes[key].map do |value|
          Paysafe.const_get(klass).new(value)
        end
      end
    end

  end
end
