require 'paysafe/result'

module Paysafe
  class Card < Result

    BRANDS = {
      'AM' => 'american_express',
      'DC' => 'diners_club',
      'DI' => 'discover',
      'JC' => 'jcb',
      'MC' => 'master',
      'MD' => 'maestro',
      'SF' => 'swiff',
      'SO' => 'solo',
      'VI' => 'visa',
      'VD' => 'visa_debit',
      'VE' => 'visa_electron',
    }

    attributes :id, :nick_name, :merchant_ref_num, :holder_name,
      :card_num, :card_bin, :last_digits, :card_type, :billing_address_id,
      :default_card_indicator, :payment_token, :single_use_token, :status,
      :cvv, :track1, :track2, :type

    object_attribute :CardExpiry, :card_expiry
    object_attribute :Address, :billing_address

    def brand
      @brand ||= BRANDS[card_type] || BRANDS[type]
    end
  end
end
