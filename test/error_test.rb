require 'test_helper'

class ErrorTest < Minitest::Test

  def test_returns_conflict_error_class
    response = {:error=>{:code=>"7503", :message=>"Card number already in use - d63b2910-9ab5-4803-a2a2-1aadcc790cc2", :links=>[{:rel=>"errorinfo", :href=>"https://developer.optimalpayments.com/en/documentation/customer-vault-api/error-7503"}]}, :links=>[{:rel=>"existing_entity", :href=>"https://api.test.netbanx.com/customervault/v1/cards/d63b2910-9ab5-4803-a2a2-1aadcc790cc2"}]}

    error = OptimalPayments::Error.error_from_response(response, 409)

    assert_kind_of OptimalPayments::Error::Conflict, error
    assert_equal "Card number already in use - d63b2910-9ab5-4803-a2a2-1aadcc790cc2", error.message
    assert_equal 409, error.code
    assert_equal response, error.response
  end

  def test_returns_internal_server_error_class
    response = {:error=>{:code=>"1002", :message=>"Internal error", :links=>[{:rel=>"errorinfo", :href=>"https://developer.optimalpayments.com/en/documentation/card-payments-api/error-1002"}]}}

    error = OptimalPayments::Error.error_from_response(response, 500)

    assert_kind_of OptimalPayments::Error::InternalServerError, error
    assert_equal "Internal error", error.message
    assert_equal 500, error.code
    assert_equal response, error.response
  end

  def test_returns_general_error_class_for_unrecognized_code
    response = {error: {code: '9876', message: 'A custom error message'}}

    error = OptimalPayments::Error.error_from_response(response, 431)

    assert_kind_of OptimalPayments::Error, error
    assert_equal "A custom error message", error.message
    assert_equal 431, error.code
    assert_equal response, error.response
  end

  def test_default_error_message_if_unrecognized_body
    error = OptimalPayments::Error.error_from_response('', 431)
    assert_equal "An unknown error has occurred.", error.message

    error = OptimalPayments::Error.error_from_response(nil, 431)
    assert_equal "An unknown error has occurred.", error.message

    error = OptimalPayments::Error.error_from_response({ error: {} }, 431)
    assert_equal "An unknown error has occurred.", error.message
  end

end
