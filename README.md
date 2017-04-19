# The Paysafe Ruby Gem

[![Gem Version](https://badge.fury.io/rb/paysafe.svg)][gem]
[![Build Status](https://travis-ci.org/javierjulio/paysafe.svg?branch=master)][travis]

A well tested Ruby interface to the [Paysafe REST API](paysafe_api_reference) (formerly Optimal Payments). Requires Ruby 2.3 and up. Not all API actions are supported yet. Since the Paysafe API uses camelCase, this gem will handle converting to and from snake_case for you.

## Installation

Add the following to your application's Gemfile:

```ruby
gem 'paysafe'
```

Or install directly with `gem install paysafe`.

To try out the gem, just follow the Development section instructions as the built in setup script will direct you on how to provide the necessary API info.

## Usage

TODO: Write usage instructions here

## Development

1. `git clone https://github.com/javierjulio/paysafe.git`
2. Run `./bin/setup` to install dependencies and fill out API key info
3. Run `./bin/console` for an interactive prompt with an authenticated client for you to experiment:

    ```ruby
    profile = client.create_profile(merchant_customer_id: '123', locale: 'en_US')
    puts profile.id
    # => b088ac37...
    ```

All code is written in snake_case since requests and responses are converted to and from camelCase for you.

### Tests

Run `bundle exec rake test` or to skip integration tests run with `SKIP_INTEGRATION=true`.

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests for missing API support are welcome on GitHub at https://github.com/javierjulio/paysafe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[gem]: https://rubygems.org/gems/paysafe
[travis]: https://travis-ci.org/javierjulio/paysafe
[paysafe_api_reference]: https://developer.paysafe.com/en/api-reference/
