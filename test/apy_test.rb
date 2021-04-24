# frozen_string_literal: true

require "test_helper"

class ApyTest < Minitest::Test
  include Apy::Calculate

  def test_weighted_harmonic_mean
    inputs = [
      [1000, 156.23],
      [1000, 156.30],
      [1000, 173.15],
      [1000, 188.72],
      [1000, 204.61],
      [1000, 178.23]
    ]
    actual = weighted_harmonic_mean(inputs)

    assert_in_delta 174.57, actual, 0.01
  end

  def test_compound
    monthly_actual = compound(1200, rate: 0.1, times: 12, terms: 1)
    weekly_actual = compound(1200, rate: 0.1, times: 52, terms: 1)
    daily_actual = compound(1200, rate: 0.1, times: 365, terms: 1)

    assert_in_delta 1325.66, monthly_actual, 0.01
    assert_in_delta 1326.07, weekly_actual, 0.01
    assert_in_delta 1326.19, daily_actual, 0.01
  end
end
