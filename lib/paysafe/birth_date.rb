require 'paysafe/result'

module Paysafe
  class BirthDate < Paysafe::Result
    generate_attr_reader :year, :month, :day
  end
end
