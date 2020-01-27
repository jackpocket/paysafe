require 'paysafe/result'

module Paysafe
  class GatewayResponse < Result
    attributes :processor,
      :balance,
      :merchant_transaction_id,
      :payment_processor_transaction_id,
      :lcp_transaction_id,
      :lcp_encoded_transaction_id
  end
end
