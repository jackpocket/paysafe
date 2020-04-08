require 'paysafe/result'

module Paysafe
  class StandaloneCredit < Result
    attributes :id,
      :payment_type,
      :payment_handle_token,
      :merchant_ref_num,
      :currency_code,
      :txn_time,
      :status,
      :gateway_reconciliation_id,
      :amount,
      :live_mode,
      :updated_time,
      :status_time

    object_attribute :Address, :billing_details
    object_attribute :Customer, :profile
    object_attribute :GatewayResponse, :gateway_response
    object_attribute :PaymentProcessor, :sightline
  end
end
