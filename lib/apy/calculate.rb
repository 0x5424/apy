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

    # Simple compound
    # @param principal [Numeric] Initial investment
    # @param apy [Float] Expected interest rate for 1y
    # @param times [Integer] Times the interest will be paid out over 1y
    # @param terms [Integer] Number of years
    def compound(principal, apy:, times:, terms:)
      total_rate = 1 + (apy / times)

      principal * (total_rate**(times * terms))
    end
  end
end
