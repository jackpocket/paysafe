# The Paysafe Ruby Gem

[![Gem Version](https://badge.fury.io/rb/paysafe.svg)][gem]
[![Build Status](https://travis-ci.org/javierjulio/paysafe.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/paysafe
[travis]: https://travis-ci.org/javierjulio/paysafe

A well tested Ruby interface to the Paysafe REST API (formerly Optimal Payments). Note: requires Ruby 2.3 and up. Not all API actions are supported but the essential ones are there.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paysafe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paysafe

To try out the gem and experiment, just follow the Development section instructions.

## Usage

TODO: Write usage instructions here

## Development

1. Clone the repo: `git clone https://github.com/javierjulio/paysafe.git`
2. From project root run `./bin/setup` script
3. Run `./bin/console` for an interactive prompt with an authenticated client for you to experiment:

  ```ruby
  profile = client.create_profile(merchant_customer_id: '123', locale: 'en_US')
  puts profile.id
  # => b088ac37...
  ```

Using this library, any parameters sent or responses are in snake_case despite the Paysafe REST API using camel case. All payloads in snake_case will be converted to camelCase automatically and responses in reverse as noted in the example above.

### Tests

Run `bundle exec rake test` or to skip integration tests run with `SKIP_INTEGRATION=true`.

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests for missing API support are welcome on GitHub at https://github.com/javierjulio/paysafe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
