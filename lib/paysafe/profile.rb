require 'paysafe/result'

module Paysafe
  class Profile < Paysafe::Result
    generate_attr_reader :id, :status, :merchant_customer_id,
      :locale, :first_name, :middle_name, :last_name,
      :ip, :gender, :nationality, :email, :phone, :cell_phone,
      :payment_token, :addresses, :cards

    object_attr_reader :BirthDate, :date_of_birth
    object_attr_reader :Card, :cards
    object_attr_reader :Address, :addresses
  end
end
