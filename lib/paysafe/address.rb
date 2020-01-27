require 'paysafe/result'

module Paysafe
  class Address < Result
    attributes :id, :nick_name, :street, :street1, :street2, :city,
      :country, :state, :zip, :recipient_name, :phone, :status,
      :default_shipping_address_indicator
  end
end
