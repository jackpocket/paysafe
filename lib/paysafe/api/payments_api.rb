module Paysafe
  module Api
    class PaymentsApi < BaseApi

      def get_payment_methods(currency_code:)
        perform_get_with_object("/paymenthub/v1/paymentmethods?currencyCode=#{currency_code}", PaymentMethods)
      end

      def create_payment(**data)
        perform_post_with_object("/paymenthub/v1/payments", data, Payment)
      end

      def get_payment(id:)
        perform_get_with_object("/paymenthub/v1/payments/#{id}", Payment)
      end

    end
  end
end
