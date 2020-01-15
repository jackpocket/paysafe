module Paysafe
  module Api
    class CardPaymentsApi < BaseApi

      def create_verification_from_token(merchant_ref_num:, token:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          card: {
            payment_token: token
          }
        })

        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/verifications", data, Verification)
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

        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/auths", data, Authorization)
      end

      def verify_card(merchant_ref_num:, number:, month:, year:, cvv:, address:, **args)
        data = args.merge({
          merchant_ref_num: merchant_ref_num,
          billing_details: address,
          card: {
            card_num: number,
            cvv: cvv,
            card_expiry: {
              month: month,
              year: year
            }
          }
        })

        perform_post_with_object("/cardpayments/v1/accounts/#{account_number}/verifications", data, Verification)
      end

    end
  end
end
