require 'paysafe/result'

module Paysafe
  class Authorization < Paysafe::Result
    generate_attr_reader :id, :merchant_ref_num, :amount, :settle_with_auth,
      :pre_auth, :available_to_settle, :child_account_num, :auth_code,
      :recurring, :customer_ip, :dup_check, :description, :txn_time,
      :currency_code, :avs_response, :cvv_verification, :status, :keywords

    object_attr_reader :Card, :card
    object_attr_reader :Profile, :profile
    object_attr_reader :Address, :billing_details
  end
end
