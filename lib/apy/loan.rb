# frozen_string_literal: true

require_relative "interest"

module Apy
  # A loan object; Provides helpers for calculating various debt-related scenarios
  class Loan
    attr_reader :borrow, :apy

    # @param borrow [Numeric] Amount of money to be borrowed
    # @param apy [Float] The interest rate of the borrowed money
    def initialize(borrow, apy:)
      fail(ArgumentError, "apy must be a positive Float") unless apy.positive? && apy.is_a?(Float)

      @borrow = borrow
      @apy = apy
    end

    # Based on the borrow amount, calculate the payment size required to pay off the principal and accrued interest
    # @param days [Integer] Days until the loan is fully paid off
    # @param times [Integer] The number of times per term interest is accrued; Defaults to 1 (flat rate)
    # @param days_per_term [Integer] The number of days per interest term
    # @param payments_per_term [Integer] The number of payments made towards the loan per term; Defaults to `times`
    # @example Payment size for 1200, interest accrued once, repaid in 1 payment across 365 days:
    #   d1 = Date.parse "2020-01-01"
    #   d2 = Date.parse "2021-01-01"
    #   days = (d2 - d1).round # => 365
    #   Loan.new(1200, apy: 0.1).payment_size(days: days) == 1320.0
    # @example Payment size for 1200, interest accrued once, repaid in 12 payments across 365 days:
    #   Loan.new(1200, apy: 0.1).payment_size(days: days, payments_per_term: 12) == 110.0
    # @example Payment size for 1200, interest accrued 12 times, repaid in 12 payments across 365 days:
    #   Loan.new(1200, apy: 0.1).payment_size(days: days, times: 12) == 110.47
    def payment_size(days:, times: 1, days_per_term: days, payments_per_term: times)
      total_owed(
        days: days,
        times: times,
        days_per_term: days_per_term
      ) / (payments_per_term * Interest.get_term_size(days, days_per_term))
    end

    # Get the total amount owed, based on the start & end date
    # @param days [Integer] Days until the loan is fully paid off
    # @param times [Integer] The number of times per term interest is accrued; Defaults to 1 (flat rate)
    # @param days_per_term [Integer] The number of days per interest term
    # @see Interest#total
    # @see #adjusted_apy
    def total_owed(days:, times: 1, days_per_term: days)
      Apy::Interest.new(
        apy: adjusted_apy(days, days_per_term),
        days: days,
        days_per_term: days_per_term
      ).total(borrow, times: times)
    end

    # Similar to payment_size, except interest accrues based on the remaining debt
    # @note This currently only works with years... should refactor this to accept alternative ranges
    # @todo Once finished, make #payment_size accept less args (lump-sum, _only_ accept payment count)
    # @example Amortized payment size for 100000@10%, repaid over 20 years
    #   Loan.new(100000, apy: 0.1).amortized_payment_size(terms: 20, times: 12) == 965.0216
    def amortized_payment_size(terms:, times: 12, days_per_term: 365)
      years = (terms * days_per_term) / 365

      (apy * borrow) / (times * (1 - ((1 + (apy / times))**(-1 * times * years))))
    end

    # @todo Once finished, make #total_owed accept less args (lump-sum, _only_ accept payment count)
    # @example Amortized total owed on 100000@10%, repaid over 20 years
    #   Loan.new(100000, apy: 0.1).amortized_payment_size(terms: 20, times: 12) == 231605.2
    def amortized_total_owed(terms:, times: 12, days_per_term: 365)
      size = amortized_payment_size(terms: terms, times: times, days_per_term: days_per_term)

      times * size * terms
    end

    private

    # In the event days & days_per_term diverges, calculate an adjusted apy
    # `apy / (days / days_per_term)`
    # @example A 10% APY, but interest is to be calculated _per day_:
    #   Interest.new(apy: 0.1).send(:adjusted_apy, 365, 1) == 0.00027397260273972606 # % per day
    def adjusted_apy(days, days_per_term)
      apy / (days / days_per_term)
    end
  end
end
