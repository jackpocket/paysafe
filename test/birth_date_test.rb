require 'test_helper'

class BirthDateTest < Minitest::Test

  def test_date
    result = Paysafe::BirthDate.new(year: 1983, month: 2, day: 1)

    assert_equal result.date, Date.new(1983, 2, 1)
    assert_equal result.year, 1983
    assert_equal result.month, 2
    assert_equal result.day, 1
  end

end
