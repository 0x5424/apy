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
    def payment_size(days:, times: 1, days_per_term: 365, payments_per_term: times)
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
    # @note Because the constructor accepts an APY for the year, an adjusted rate is used here based on days_per_term
    # @see Interest#total
    # @see #adjusted_apy
    def total_owed(days:, times: 1, days_per_term: 365)
      Apy::Interest.new(
        apy: adjusted_apy(days, days_per_term),
        days: days,
        days_per_term: days_per_term
      ).total(borrow, times: times)
    end

    # Similar to payment_size, except interest accrues based on the remaining debt
    # @todo Finish this
    # @todo Once finished, make #payment_size accept less args (lump-sum, _only_ accept payment count)
    # @example Amortized payment size for 1200, interest accrued 12 times, repaid in 12 payments across 365 days:
    #   Loan.new(1200, apy: 0.1).amortized_payment_size(days: days, times: 12) == 105.50
    def amortized_payment_size(days:, times: 1, days_per_term: 365, payments_per_term: times)
      fail
    end

    # @todo Finish this
    # @todo Once finished, make #total_owed accept less args (lump-sum, _only_ accept payment count)
    def amortized_total_owed(days:, times: 1, days_per_term: 365, payments_per_term: times)
      fail
    end

    private

    # `apy / (days / days_per_term)`
    def adjusted_apy(days, days_per_term)
      apy / (days / days_per_term)
    end
  end
end
