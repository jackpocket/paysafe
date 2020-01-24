require 'paysafe/result'

module Paysafe
  class PaymentMethod < Result
    attributes :payment_method, :currency_code, :currency, :account_id, :mcc
  end
end
