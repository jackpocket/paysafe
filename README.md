# The OptimalPayments Ruby Gem

A tested Ruby interface to the OptimalPayments API. Note: Requires Ruby 2.0 and up. Not all API actions are supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'optimal_payments'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optimal_payments

## Usage

TODO: Write usage instructions here

## Development

Clone the repository:

    $ git clone https://github.com/javierjulio/optimal_payments.git

Run the setup script from the project root:

    $ ./bin/setup

Run tests:

    $ bundle exec rake test

Run console for an interactive prompt with an authenticated client for you to experiment:

    $ ./bin/console
    # ...
    profile = authenticated_client.create_profile(merchantCustomerId: '123', locale: 'en_US')

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/javierjulio/optimal_payments. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
