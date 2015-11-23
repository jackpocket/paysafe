require 'test_helper'

class ErrorTest < Minitest::Test

  def test_returns_conflict_error_class
    response = {:error=>{:code=>"7503", :message=>"Card number already in use - d63b2910-9ab5-4803-a2a2-1aadcc790cc2", :links=>[{:rel=>"errorinfo", :href=>"https://developer.optimalpayments.com/en/documentation/customer-vault-api/error-7503"}]}, :links=>[{:rel=>"existing_entity", :href=>"https://api.test.netbanx.com/customervault/v1/cards/d63b2910-9ab5-4803-a2a2-1aadcc790cc2"}]}

    error = Paysafe::Error.error_from_response(response, 409)

    assert_instance_of Paysafe::Error::Conflict, error
    assert_kind_of Paysafe::Error::ClientError, error
    assert_equal "Card number already in use - d63b2910-9ab5-4803-a2a2-1aadcc790cc2", error.message
    assert_equal '7503', error.code
    assert_equal response, error.response
  end

  def test_returns_bad_gateway_error_class
    response = {:error=>{:code=>"3028", :message=>"The external processing gateway has reported a system error.", :links=>[{:rel=>"errorinfo", :href=>"https://developer.optimalpayments.com/en/documentation/card-payments-api/error-3028"}]}}

    error = Paysafe::Error.error_from_response(response, 502)

    assert_instance_of Paysafe::Error::BadGateway, error
    assert_kind_of Paysafe::Error::ServerError, error
    assert_equal "The external processing gateway has reported a system error.", error.message
    assert_equal '3028', error.code
    assert_equal response, error.response
  end

  def test_returns_general_error_class_for_unrecognized_code
    response = {error: {code: '9876', message: 'A custom error message'}}

    error = Paysafe::Error.error_from_response(response, 431)

    assert_instance_of Paysafe::Error, error
    assert_equal "A custom error message", error.message
    assert_equal '9876', error.code
    assert_equal response, error.response
  end

  def test_no_error_message_if_unrecognized_body
    error = Paysafe::Error.error_from_response('', 431)
    assert_equal "", error.message

    error = Paysafe::Error.error_from_response(nil, 431)
    assert_equal "", error.message
  end

end
