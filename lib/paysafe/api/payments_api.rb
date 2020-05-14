module Paysafe
  module Api
    class PaymentsApi < BaseApi

      def get_payment_methods(currency_code:)
        perform_get_with_object("/paymenthub/v1/paymentmethods?currencyCode=#{currency_code}", PaymentMethods)
      end

      def create_customer(**data)
        perform_post_with_object("/paymenthub/v1/customers", data, Customer)
      end

      def create_single_use_customer_token(id:)
        perform_post_with_object("/paymenthub/v1/customers/#{id}/singleusecustomertokens", {}, SingleUseToken)
      end

      def create_payment(**data)
        perform_post_with_object("/paymenthub/v1/payments", data, Payment)
      end

      def create_standalone_credit(**data)
        perform_post_with_object("/paymenthub/v1/standalonecredits", data, StandaloneCredit)
      end

      def get_customer(id:)
        perform_get_with_object("/paymenthub/v1/customers/#{id}", Customer)
      end

      def get_payment(id:)
        perform_get_with_object("/paymenthub/v1/payments/#{id}", Payment)
      end

      def get_standalone_credit(id:)
        perform_get_with_object("/paymenthub/v1/standalonecredits/#{id}", StandaloneCredit)
      end

    end
  end
end
