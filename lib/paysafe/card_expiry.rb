require 'paysafe/result'

module Paysafe
  class CardExpiry < Paysafe::Result
    generate_attr_reader :year, :month
  end
end
