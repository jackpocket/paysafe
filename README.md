# The Paysafe Ruby Gem

[![Gem Version](https://badge.fury.io/rb/paysafe.svg)][gem]
![Build Status](https://github.com/javierjulio/paysafe/workflows/Paysafe/badge.svg?branch=master)

A well tested Ruby interface to the [Paysafe REST API](paysafe_api_reference) (formerly Optimal Payments). Requires Ruby 2.4 and up. Not all API actions are supported yet. Since the Paysafe API uses camelCase, this gem will handle converting to and from snake_case for you.

## Installation

Add the following to your application's Gemfile:

```ruby
gem 'paysafe'
```

Or install directly with `gem install paysafe`.

To try out the gem, just follow the Development section instructions as the built in setup script will direct you on how to provide the necessary API info.

## Usage

### Client Configuration

Create and configure a client with your API authentication.

```ruby
client = Paysafe::REST::Client.new(
  api_key: 'your api key',
  api_secret: 'you api secret',
  test_mode: false, # to enable Production requests (default is true)
  account_number: '1234', # used for the Card Payments API
  # Provide optional timeouts
  # timeouts: { connect: 2, read: 5, write: 10 }
)
```

At a minimum the following options: `api_key`, `api_secret`, and `test_mode` should be specified. The `account_number` is only necessary for certain API's such as the Card Payments API.

### Making Requests

Make an API request with a payload in the structure documented by the [Paysafe REST API](paysafe_api_reference) but using snake_case. The request payload will be converted to camelCase for you.

```ruby
profile = client.customer_vault.create_profile(
  merchant_customer_id: '123',
  locale: 'en_US',
  card: {
    card_num: '4111111111111111',
    card_expiry: {
      month: 12,
      year: 2020
    }
  }
)
```

### Handling Responses

Response data is in snake_case (converted from camelCase) typed with individual methods and predicates, including nested complex objects and array of objects as shown below:

```ruby
profile.id?
# => true
profile.id
# => b088ac37...
profile.cards.first.card_expiry.year
# => 2020
```

Further API methods are provided in the `Paysafe::REST::Client` object.

## Development

1. `git clone https://github.com/javierjulio/paysafe.git`
2. Run `./bin/setup` to install dependencies and fill out API key/secret info
3. Run `./bin/console` for an interactive prompt with an authenticated client for you to experiment:

    ```ruby
    profile = client.customer_vault.create_profile(merchant_customer_id: SecureRandom.uuid, locale: 'en_US')
    puts profile.id
    # => b088ac37...
    ```

All code is written in snake_case since requests and responses are converted to and from camelCase for you.

### Tests

If the API key/secret info is different from what was used to record the cassettes, you'll need to run `bundle exec rake test RECORD_MODE=all` otherwise run `bundle exec rake test`.

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests for missing API support are welcome on GitHub at https://github.com/javierjulio/paysafe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[gem]: https://rubygems.org/gems/paysafe
[paysafe_api_reference]: https://developer.paysafe.com/en/api-reference/
