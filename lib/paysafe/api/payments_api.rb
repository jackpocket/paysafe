module Paysafe
  module Api
    class PaymentsApi < BaseApi

      def get_payment_methods(currency_code:)
        perform_get_with_object("/paymenthub/v1/paymentmethods?currencyCode=#{currency_code}", PaymentMethods)
      end

    end
  end
end
