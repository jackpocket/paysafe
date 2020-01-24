require 'paysafe/result'

module Paysafe
  class PaymentMethods < Result
    object_attribute :PaymentMethod, :payment_methods
  end
end
