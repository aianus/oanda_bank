oanda_bank
==========

Ruby Money::Bank interface for OANDA currency rate data

This gem extends Money::Bank::VariableExchange with Money::Bank::OANDA to give you access to OANDA fxTrade exchange rates.

## What rates are available?

Any pair of currencies that are both part of the money gem and part of a tradeable instrument in your fxTrade account. In addition, if there is no tradeable instrument containing both of your currencies the gem will attempt to go through USD. For example, CAD -> SEK is supported because although there is no CAD/SEK instrument, there exist both USD/CAD and USD/SEK instruments.

## Usage

``` ruby
require 'oanda_bank'

oanda_bank = Money::Bank::OANDA.new(ENV['FXTRADE_ACCOUNT_ID'], ENV['FXTRADE_ACCESS_TOKEN'])

# Call this before calculating exchange rates
# This will download the rates from OANDA
oanda_bank.update_rates!

# Exchange 100 USD to CAD
# API is the same as the money gem
oanda_bank.exchange_with(Money.new(10000, :USD), :CAD)

# Set as default bank to do arithmetic and comparisons on Money objects
Money.default_bank = oanda_bank
money1 = Money.new(10)
money1.bank # oanda_bank

Money.us_dollar(10000).exchange_to(:CAD)
'1'.to_money(:USD) > '1'.to_money(:CAD) # true

# Refresh rates after some number of seconds (by default, rates are only updated when you call update_rates!)
oanda_bank.ttl_in_seconds = 3600 # Cache rates for one hour
```

## Testing

If you'd like to contribute code or modify this gem, you can run the test suite with:

```ruby
gem install oanda_bank --dev
bundle exec rspec
```

## Contributing

1. Fork this repo and make changes in your own copy
2. Add a test if applicable and run the existing tests with `rspec` to make sure they pass
3. Commit your changes and push to your fork `git push origin master`
4. Create a new pull request and submit it back to me
