require 'paysafe/result'

module Paysafe
  class SingleUseToken < Paysafe::Result
    generate_attr_reader :id, :payment_token, :time_to_live_seconds

    object_attr_reader :Card, :card
    object_attr_reader :Address, :billing_address
  end
end
