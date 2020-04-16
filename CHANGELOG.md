Changelog
=========

## Unreleased

* Removed deprecated methods on `Client` object. Please use API scoped methods defined on `payments`, `customer_vault`, or `card_payments`.

## 0.11.0 (2020-04-08)

* Added standalone credits support for Payments API:
  * `client.payments.create_standalone_credit`
  * `client.payments.get_standalone_credit`

## 0.10.0 (2020-02-24)

* Removed client configuration using a block.
* Deprecated `Client` object API methods.
* All API methods are now grouped by API objects, for example:
  * Customer Vault API: `client.create_profile` is now `client.customer_vault.create_profile`
  * Card Payments API: `client.create_verification` is now `client.card_payments.create_verification`
  * Includes some methods for new Payments API through `client.payments` (aka Paysafe Unity Platform)
* Requires http gem v4.
* Requires Ruby 2.4 and up.
* Added Ruby 2.7 build to CI.

## 0.9.4 (2019-09-24)

* Relax http gem dependency to allow v2 through v4.

## 0.9.3 (2017-12-19)

* Relax http gem dependency to allow v2 or v3.
* Use additional args for `purchase` method.

## 0.9.2 (2017-04-27)

* Added predicate methods for checking CVV and AVS status on a verification request, e.g. `cvv_match?`, `avs_no_match?`, etc.

## 0.9.1 (2017-04-24)

* Added `card.brand` method that converts `card_type` value (VI) to brand name (visa).

## 0.9.0 (2017-04-19)

This is a major update with breaking changes so moving the version up quite a bit since I'd also like to move to a 1.0 release soon after.

* Requires Ruby 2.3 and up.
* All API methods now accept params in snake_case and are converted to camelCase.
* Responses are now typed with classes using snake_case properties (converted from camelCase) handling nested complex objects and lazily loaded. No more hashes.
* Field names match Paysafe API docs except when making requests and working with responses, its all in snake_case.
* Renamed config `timeout_options` renamed to `timeouts`.
* Removed default value for `timeouts` config.
* Added new methods to work with single use tokens:
  * `create_single_use_token` (requires different API key and secret)
  * `create_verification_from_token`
  * `create_profile_from_token`
  * `create_card_from_token`
* Updated `bin/setup` script.
* Updated API base domain to paysafe.com.

## 0.6.2 (2016-04-25)

* Upgrade http gem to v2.0

## 0.6.1 (2016-03-02)

* Add `update_profile` method to client
