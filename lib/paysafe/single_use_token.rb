require 'paysafe/result'

module Paysafe
  class SingleUseToken < Result
    attributes :id, :payment_token, :time_to_live_seconds

    object_attribute :Card, :card
    object_attribute :Address, :billing_address
  end
end
