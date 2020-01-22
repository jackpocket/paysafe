require 'paysafe/result'

module Paysafe
  class Verification < Result
    attributes :id, :merchant_ref_num, :child_account_num,
      :auth_code, :customer_ip, :dup_check, :description, :txn_time,
      :currency_code, :avs_response, :cvv_verification, :status

    object_attribute :Profile, :profile
    object_attribute :Card, :card
    object_attribute :Address, :billing_details

    [:unknown, :not_processed, :no_match, :match, :match_address_only, :match_zip_only].each do |key|
      define_method("avs_#{key}?") do
        avs_response.to_s.upcase == key.to_s.upcase
      end
    end

    [:unknown, :match, :no_match, :not_processed].each do |key|
      define_method("cvv_#{key}?") do
        cvv_verification.to_s.upcase == key.to_s.upcase
      end
    end
  end
end
