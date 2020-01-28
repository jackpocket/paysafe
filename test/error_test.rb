require 'test_helper'

class ErrorTest < Minitest::Test

  def test_error_response
    response_body = { error: { code: '3009', message: 'message' } }
    error = Paysafe::Error.from_response(response_body, 402)
    assert_equal response_body, error.response
  end

  def test_error_code
    error = Paysafe::Error.from_response({ error: { code: '3009' } }, 402)
    assert_equal "3009", error.code
  end

  def test_error_message
    error = Paysafe::Error.from_response({ error: { code: '3009', message: 'Message' } }, 402)
    assert_equal "Message (Code 3009)", error.message
  end

  def test_blank_error_message_if_unrecognized_body
    error = Paysafe::Error.from_response('', 431)
    assert_equal "", error.message

    error = Paysafe::Error.from_response(nil, 431)
    assert_equal "", error.message
  end

  def test_error_message_with_fields_and_details
    response = {
      error: {
        code: "3009",
        message: "Message",
        details: [ "access denied" ],
        field_errors: [
          { field: "locale", error: "may not be empty" },
          { field: "merchantCustomerId", error: "may not be empty" }
        ]
      }
    }
    error = Paysafe::Error.from_response(response, 409)

    assert_equal "Message (Code 3009) Field Errors: The \`locale\` may not be empty. The \`merchantCustomerId\` may not be empty. Details: access denied", error.message
  end

  def test_error_message_with_details
    error = Paysafe::Error.from_response({ error: { code: '3009', message: 'Message', details: [ "access denied" ] } }, 402)
    assert_equal "Message (Code 3009) Details: access denied", error.message
  end

  def test_general_error_class_used_for_unrecognized_http_status
    error = Paysafe::Error.from_response({}, 431)
    assert_instance_of Paysafe::Error, error
  end

  def test_specific_error_class_used_for_matching_http_status
    Paysafe::Error::ERRORS_BY_STATUS.each do |status, klass|
      assert_instance_of klass, Paysafe::Error.from_response({}, status)

      if (400..499).cover?(status)
        assert_kind_of Paysafe::Error::ClientError, Paysafe::Error.from_response({}, status)
      end

      if (500..599).cover?(status)
        assert_kind_of Paysafe::Error::ServerError, Paysafe::Error.from_response({}, status)
      end
    end
  end

end
