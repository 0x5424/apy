# frozen_string_literal: true

module Apy
  module Calculate
    # Calculate the weighted harmonic mean for a set of values
    # (∑w) / (∑w/i)
    # @param matrix [Array<Array<(Numeric, Numeric)>>] Matrix whose size is the number of investments, with the following array elements: idx0 invested amount, idx1 purchase price of the asset
    # @todo Can make this a bit more performant with `inject`
    # @example Providing a set of DCA values
    #   dca = [[1000,156.23],[1000,156.3], [1000,173.15],[1000,188.72], [1000,204.61],[1000,178.23]]
    #   weighted_harmonic_mean(dca)
    #   # => 174.5655590168175
    def weighted_harmonic_mean(matrix)
      sum = matrix.sum { |(n, _)| n }.to_f

      total_weight = []
      weighted_values = []

      matrix.each do |(investment, price)|
        weight = investment / sum

        total_weight << weight
        weighted_values << (weight / price)
      end

      total_weight.sum / weighted_values.sum
    end

    # Simple compound, assuming no additional investment over successive maturity terms
    # @param principal [Numeric] Initial investment
    # @param rate [Float] Expected interest rate for the length of the period
    # @param times [Integer] Times the interest will be paid out per term
    # @param terms [Integer] Number of terms
    #
    # @example Given a "10% APY", with interest paid monthly (1y maturity date):
    #   compound(1200, rate: 0.1, times: 12, terms: 1) == 1325.66
    #
    # @example Given a "0.1923% WPY", with interest paid weekly (1w maturity date):
    #   compound(1200, rate: 0.1, times: 52, terms: 1) == 1326.07
    #   compound(1200, rate: 0.001923, times: 1, terms: 52) == 1326.07
    #
    # @example Given a "0.0274% DPY", with interest paid daily (1d maturity date):
    #   compound(1200, rate: 0.1, times: 365, terms: 1) == 1326.19
    #   compound(1200, rate: 0.000274, times: 1, terms: 365) == 1326.20
    def compound(principal, rate:, times:, terms:)
      total_rate = 1 + (rate / times)

      principal * (total_rate**(times * terms))
    end

    # "DCA" compound, assuming a recurring investment continuously added to the principal amount, this new amount _additionally_ compounded for the next period
    # @param matrix [Array<Array(Numeric, Numeric)>] Matrix whose size is the number of terms; Each array item has the following elements: idx0 additional investment, idx1 the expected rate for the term
    # @param times [Integer] Times the interest will be paid out per term
    # @example Continuously investing 1200 dollars a year into a contract with a "10% APY", interest paid out once a month
    #   dca_compound([[1200, 0.1], [1200, 0.1]], times: 12) == 2790.125
    #
    # @todo Clean this up, there is most likely an optimized formula for this 🤨
    # @see #compound
    def dca_compound(matrix, times:)
      result = matrix.each_with_object(
        total: 0,
        interest: 0,
        data: {
          0 => {
            ytd: 0,
            in: 0,
            interest: 0
          }
        }
      ).with_index do |(ary, out), i|
        additional_investment, rate = ary
        prev_ytd = out[:data][i][:ytd]

        to_compound = prev_ytd + additional_investment

        current = compound(to_compound, rate: rate, times: times, terms: 1)
        interest_this_period = current - to_compound

        out[:total] += additional_investment + interest_this_period
        out[:interest] += interest_this_period
        out[:data][i + 1] = {ytd: current, in: additional_investment, interest: interest_this_period}
      end

      result.fetch(:total)
    end
  end
end
