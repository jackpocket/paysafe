require 'paysafe/result'

module Paysafe
  class Customer < Result
    attributes :id, :status, :merchant_customer_id, :locale,
      :ip, :first_name, :middle_name, :last_name, :gender,
      :nationality, :email, :phone, :cell_phone, :payment_token

    object_attribute :BirthDate, :date_of_birth
  end
end
