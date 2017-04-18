require 'paysafe/result'

module Paysafe
  class Address < Paysafe::Result
    generate_attr_reader :id, :nick_name, :street, :street2, :city,
      :country, :state, :zip, :recipient_name, :phone, :status,
      :default_shipping_address_indicator
  end
end
