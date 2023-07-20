require 'paysafe/result'

module Paysafe
  class SingleUseCustomerToken < Result
    attributes :id, :payment_token, :time_to_live_seconds, :customer_id,
      :status, :single_use_customer_token, :locale, :first_name, :last_name,
      :email

    object_attribute :Address, :addresses
    object_attribute :PaymentHandle, :payment_handles
  end
end
