# Apy

Various helpers for calculating interest

## TODO
- [ ] Amortization
- [ ] Update method signatures to only use day counts
- [ ] Comprehensive examples w/ tests
- [ ] Setup ci

## Installation

Add this line to your application's Gemfile:

```ruby
gem "apy"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install apy

## Usage

- [As a module](#as-a-module)
  - [Method: `weighted_harmonic_mean`](#weighted-harmonic-mean)
  - [Method: `compound`](#compound)
- [Interest class](#interest)
- [Loan class](#loan)


### As a Module
`Apy::Calculable` is the base module with the most exposed utility. Simply include it in a class which needs the functionality.

#### `weighted_harmonic_mean`
[Link](https://www.investopedia.com/terms/h/harmonicaverage.asp#mntl-sc-block_1-0-9)

Given a series of invested amounts, this can be used to effectively calculate the average share price, or DCA (dollar cost average) price of a position.

Given the following:
| Amount invested | Share price |
| --- | --- |
| 1000 | 156.23 |
| 1000 | 156.30 |
| 1000 | 173.15 |
| 1000 | 188.72 |
| 1000 | 204.61 |
| 1000 | 178.23 |

Investing a total of 6000 with the above share prices results in `174.57` for the average price paid per share.

Given the following:
| Amount invested | Share price |
| --- | --- |
| 500 | 200.00 |
| 1000 | 100.00 |

Investing a total of 1500 with the above share prices results in `100.00` for the average price paid per share.

The module method accepts a matrix, with each array in the set having the following signature `[invested_amount, share_price]`:
```ruby
dca = [
  [1000, 156.23],
  [1000, 156.30],
  [1000, 173.15],
  [1000, 188.72],
  [1000, 204.61],
  [1000, 178.23]
]
weighted_harmonic_mean(dca) == 174.5655590168175
```

#### `compound`
[Link](https://www.thecalculatorsite.com/articles/finance/compound-interest-formula.php)

Simple compound interest formula. Variable names correspond to the following:
- `principal` The base amount before interest
- `rate` The expected interest rate
- `times` The number of times interest is calculated per term
- `terms` The number of terms to allow the principal accrue interest

Example: 1200@10% over 1y, interest paid monthly
```ruby
compound(1200, rate: 0.1, times: 12, terms: 1) == 1325.66
```

#### `dca_compound`
A variant of `#compound`, wherein an amount is continually invested at varying interest rates. Similar to `weighted_harmonic_mean`, this method also accepts a matrix. The size of the matrix corresponds to the number of `terms` all funds will accrue.

Example: 1200@10% over 2y, interest paid monthly
```ruby
dca = [
  [1200, 0.1],
  [1200, 0.1]
]
dca_compound(dca, times: 12) == 2790.125
```

### Interest
todo

### Loan
todo

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fire-pls/apy.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
