require 'paysafe/result'

module Paysafe
  class CardExpiry < Result
    attributes :year, :month
  end
end
