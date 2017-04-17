# The Paysafe Ruby Gem

[![Gem Version](https://badge.fury.io/rb/paysafe.svg)][gem]
[![Build Status](https://travis-ci.org/javierjulio/paysafe.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/paysafe
[travis]: https://travis-ci.org/javierjulio/paysafe

A tested Ruby interface to the Paysafe REST API (formerly Optimal Payments). Note: requires Ruby 2.3 and up. Not all API actions are supported yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paysafe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paysafe

To try out the gem and experiment, you're better off following the development instructions.

## Usage

TODO: Write usage instructions here

## Development

1. Clone the repo: `git clone https://github.com/javierjulio/paysafe.git`
2. Use Ruby 2.1 and up. If you need to install use [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build) and then run:

        gem update --system
        gem update
        gem install bundler --no-rdoc --no-ri

3. From project root run `./bin/setup` script
4. Run `./bin/console` for an interactive prompt with an authenticated client for you to experiment:

  ```ruby
  profile = client.create_profile(merchantCustomerId: '123', locale: 'en_US')
  puts profile[:id]
  # => b088ac37...
  ```

### Tests

Run `bundle exec rake test` or to skip integration tests run with `SKIP_INTEGRATION_TESTS=true`.

### Releasing

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests for missing API support are welcome on GitHub at https://github.com/javierjulio/paysafe. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
