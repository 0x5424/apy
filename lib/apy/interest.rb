# frozen_string_literal: true

module Apy
  # An interest object; Given an apy, prepares various methods to calculate with
  class Interest
    attr_reader :apy

    # @param apy [Float] Annual/Average Percent Yield -- an expected pct return over the course of a _year_
    #
    # @example When given a positive "10%" (bond):
    #   Interest.new(apy: 0.1)
    # @example When given a negative "10%" (loan):
    #   Interest.new(apy: -0.1)
    def initialize(apy:)
      @apy = apy
    end
  end
end
