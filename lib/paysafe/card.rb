require 'paysafe/result'

module Paysafe
  class Card < Paysafe::Result
    generate_attr_reader :id, :nick_name, :merchant_ref_num, :holder_name,
      :card_num, :card_bin, :last_digits, :card_type, :billing_address_id,
      :default_card_indicator, :payment_token, :single_use_token, :status,
      :cvv, :track1, :track2, :type

    object_attr_reader :CardExpiry, :card_expiry
    object_attr_reader :Address, :billing_address
  end
end
