# frozen_string_literal: true

require "test_helper"

class ApyTest < Minitest::Test
  include Apy::Calculable

  def test_calculable_weighted_harmonic_mean
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

  def test_calculable_compound
    monthly_actual = compound(1200, rate: 0.1, times: 12, terms: 1)
    weekly_actual = compound(1200, rate: 0.1, times: 52, terms: 1)
    daily_actual = compound(1200, rate: 0.1, times: 365, terms: 1)

    assert_in_delta 1325.66, monthly_actual, 0.01
    assert_in_delta 1326.07, weekly_actual, 0.01
    assert_in_delta 1326.19, daily_actual, 0.01
  end

  def test_calculable_dca_compound
    monthly_2y_actual = dca_compound([[1200, 0.1], [1200, 0.1]], times: 12)

    assert_in_delta 2790.125, monthly_2y_actual, 0.01
  end

  def test_interest_total
    interest = Apy::Interest.new(apy: 0.1)

    annual_actual = interest.total(1200)
    monthly_actual = interest.total(1200, times: 12)

    assert_in_delta 1320.0, annual_actual, 0.01
    assert_in_delta 1325.66, monthly_actual, 0.01
  end

  def test_interest_dca
    interest = Apy::Interest.new(apy: 0.1)

    annual_actual = interest.dca(1200)
    quarterly_actual = interest.dca(300, times: 4)
    monthly_actual = interest.dca(100, times: 12)

    assert_in_delta 1320.0, annual_actual, 0.01
    assert_in_delta 1277.64, quarterly_actual, 0.01
    assert_in_delta 1267.29, monthly_actual, 0.01
  end
end
