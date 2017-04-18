require 'paysafe/result'

module Paysafe
  class Verification < Paysafe::Result
    generate_attr_reader :id, :merchant_ref_num, :child_account_num,
      :auth_code, :customer_ip, :dup_check, :description, :txn_time,
      :currency_code, :avs_response, :cvv_verification, :status

    object_attr_reader :Profile, :profile
    object_attr_reader :Card, :card
    object_attr_reader :Address, :billing_details
  end
end
