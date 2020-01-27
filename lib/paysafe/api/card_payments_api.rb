module Paysafe
  module Api
    class CardPaymentsApi < BaseApi

      def create_authorization(**data)
        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/auths", data, Authorization)
      end

      def create_verification(**data)
        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/verifications", data, Verification)
      end

      def create_verification_from_token(merchant_ref_num:, token:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          card: {
            payment_token: token
          }
        })
        create_verification(**data)
      end

      def get_authorization(id:)
        perform_get_with_object("/cardpayments/v1/accounts/#{account_number}/auths/#{id}", Authorization)
      end

      def get_verification(id:)
        perform_get_with_object("/cardpayments/v1/accounts/#{account_number}/verifications/#{id}", Verification)
      end

      def purchase(amount:, token:, merchant_ref_num:, **args)
        data = args.merge({
          amount: amount,
          merchant_ref_num: merchant_ref_num,
          settle_with_auth: true,
          card: {
            payment_token: token
          }
        })
        create_authorization(**data)
      end

    end
  end
end
