require 'paysafe/result'

module Paysafe
  class Verification < Result
    attributes :id, :merchant_ref_num, :child_account_num,
      :auth_code, :customer_ip, :dup_check, :description, :txn_time,
      :currency_code, :avs_response, :cvv_verification, :status

    object_attribute :Profile, :profile
    object_attribute :Card, :card
    object_attribute :Address, :billing_details
  end
end
