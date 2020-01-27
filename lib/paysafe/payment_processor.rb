require 'paysafe/result'

module Paysafe
  class PaymentProcessor < Result
    attributes :consumer_id
  end
end
