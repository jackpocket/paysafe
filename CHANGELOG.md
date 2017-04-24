Changelog
=========

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
