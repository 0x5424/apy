# frozen_string_literal: true

require "date"
require_relative "calculable"

module Apy
  # An interest object; Given an apy & date range, prepares various methods to calculate with
  class Interest
    include Apy::Calculable

    attr_reader :apy

    # @param apy [Float] Annual/Average Percent Yield -- an expected pct return over the course of a _year_
    # @param start_date [Date] The beginning of the interest period; Defaults to today
    # @param end_date [Date] The end of the interest period; Defaults to 1y from today
    # @param days_per_term [Integer] Days per compound interest term; Defaults to 365 days
    #
    # @example A 10% APY, intended to be used in calculations over 2y:
    #   d1 = Date.parse "2020-01-01"
    #   d2 = Date.parse "2022-01-01"
    #   Interest.new(apy: 0.1, start_date: d1, end_date: d2)
    # @example An interest object _yielding 10% over the course of 2y_:
    #   d1 = Date.parse "2020-01-01"
    #   d2 = Date.parse "2022-01-01"
    #   Interest.new(apy: 0.1, start_date: d1, end_date: d2, days_per_term: 730)
    # @example The above example, but instantiated with an apy of 5%:
    #   d1 = Date.parse "2020-01-01"
    #   d2 = Date.parse "2022-01-01"
    #   Interest.new(apy: 0.05, start_date: d1, end_date: d2)
    def initialize(apy:, start_date: Date.today, end_date: Date.today.next_year, days_per_term: 365)
      fail(ArgumentError, "apy must be a positive Float") unless apy.positive? && apy.is_a?(Float)

      @apy = apy
      @terms = Interest.get_term_size(start_date, end_date, days_per_term)
    end

    class << self
      # @param days_per_term [Integer] Number of days that pass before an entire term ends. Defaults to 365
      # @return [Integer] The actual number of terms completed
      def get_term_size(start_date, end_date, days_per_term)
        ((end_date - start_date) / days_per_term).round
      end
    end

    # Given a principal amount, return the ending balance
    # @param principal [Numeric] Initial investment
    # @param times [Integer] The number of times per term interest is accrued; Defaults to 1 (flat rate)
    # @see Calculable#compound
    def total(principal, times: 1)
      compound(principal, rate: apy, times: times, terms: @terms)
    end

    # Given a series of investments, calculate the DCA return
    # @param in_per_split [Numeric] Value of newly invested funds per term; Will be zipped with #apy & term size
    # @param times [Integer] The number of times per term interest is accrued; Defaults to 1 (flat rate)
    # @note This assumes you wish to maximize dca returns; the in_per_split is deposited before the interest is calculated
    # @note If this method is too inflexible for your use case, you should use the {Calculable} module directly
    # @see Calculable#dca_compound
    # @example Investing 3.29 everyday for a year:
    #   Apy::Interest.new(apy: 0.1).dca(3.29, times: 365) == 1263.12
    # @example Investing 23.08 every week for a year:
    #   Apy::Interest.new(apy: 0.1).dca(23.08, times: 52) == 1263.43
    # @example Investing 100 every month for a year:
    #   Apy::Interest.new(apy: 0.1).dca(23.08, times: 12) == 1267.29
    # @example Investing 300 every quarter for a year:
    #   Apy::Interest.new(apy: 0.1).dca(300, times: 4) == 1277.64
    # @example Investing 600 semi-annualy for a year:
    #   Apy::Interest.new(apy: 0.1).dca(600, times: 2) == 1292.66
    def dca(in_per_split, times: 1)
      split = @terms * times
      adjusted_apy = apy / times
      range = split.times.map { [in_per_split, adjusted_apy] }

      dca_compound(range, times: times)
    end
  end
end
