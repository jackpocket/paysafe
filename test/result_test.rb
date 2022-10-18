require 'test_helper'

class ResultTest < Minitest::Test

  def test_empty_predicate
    result = Paysafe::Result.new

    assert_equal result.empty?, true
    assert_equal result.attributes, {}
  end

end
