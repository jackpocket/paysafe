module Paysafe
  module Api
    class CardPaymentsApi < BaseApi

      def create_authorization(**data)
        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/auths", data, Authorization)
      end

      def create_verification(**data)
        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/verifications", data, Verification)
      end

      def get_authorization(id:)
        perform_get_with_object("/cardpayments/v1/accounts/#{account_number}/auths/#{id}", Authorization)
      end

      def get_verification(id:)
        perform_get_with_object("/cardpayments/v1/accounts/#{account_number}/verifications/#{id}", Verification)
      end

    end
  end
end
