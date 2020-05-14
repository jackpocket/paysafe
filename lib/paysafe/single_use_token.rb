require 'paysafe/result'

module Paysafe
  class SingleUseToken < Result
    attributes :id, :payment_token, :time_to_live_seconds, :customer_id,
      :status, :single_use_customer_token, :locale

    object_attribute :Card, :card
    object_attribute :Address, :billing_address
  end
end
