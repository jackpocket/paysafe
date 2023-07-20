require 'paysafe/result'

module Paysafe
  class PaymentHandle < Result
    attributes :id,
      :status,
      :usage,
      :payment_type,
      :payment_handle_token,
      :billing_details_id

    object_attribute :Card, :card
  end
end
