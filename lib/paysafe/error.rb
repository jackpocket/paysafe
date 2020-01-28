module Paysafe
  class Error < StandardError
    # Raised on a 4xx HTTP status code
    ClientError = Class.new(self)

    # Raised on the HTTP status code 400
    BadRequest = Class.new(ClientError)

    # Raised on the HTTP status code 401
    Unauthorized = Class.new(ClientError)

    # Raised on the HTTP status code 402
    RequestDeclined = Class.new(ClientError)

    # Raised on the HTTP status code 403
    Forbidden = Class.new(ClientError)

    # Raised on the HTTP status code 404
    NotFound = Class.new(ClientError)

    # Raised on the HTTP status code 406
    NotAcceptable = Class.new(ClientError)

    # Raised on the HTTP status code 409
    Conflict = Class.new(ClientError)

    # Raised on the HTTP status code 415
    UnsupportedMediaType = Class.new(ClientError)

    # Raised on the HTTP status code 422
    UnprocessableEntity = Class.new(ClientError)

    # Raised on the HTTP status code 429
    TooManyRequests = Class.new(ClientError)

    # Raised on a 5xx HTTP status code
    ServerError = Class.new(self)

    # Raised on the HTTP status code 500
    InternalServerError = Class.new(ServerError)

    # Raised on the HTTP status code 502
    BadGateway = Class.new(ServerError)

    # Raised on the HTTP status code 503
    ServiceUnavailable = Class.new(ServerError)

    # Raised on the HTTP status code 504
    GatewayTimeout = Class.new(ServerError)

    ERRORS = {
      400 => Paysafe::Error::BadRequest,
      401 => Paysafe::Error::Unauthorized,
      402 => Paysafe::Error::RequestDeclined,
      403 => Paysafe::Error::Forbidden,
      404 => Paysafe::Error::NotFound,
      406 => Paysafe::Error::NotAcceptable,
      409 => Paysafe::Error::Conflict,
      415 => Paysafe::Error::UnsupportedMediaType,
      422 => Paysafe::Error::UnprocessableEntity,
      429 => Paysafe::Error::TooManyRequests,
      500 => Paysafe::Error::InternalServerError,
      502 => Paysafe::Error::BadGateway,
      503 => Paysafe::Error::ServiceUnavailable,
      504 => Paysafe::Error::GatewayTimeout,
    }

    class << self
      # Create a new error from an HTTP response
      #
      # @param body [String]
      # @param status [Integer]
      # @return [Paysafe::Error]
      def from_response(body, status)
        klass = ERRORS[status] || Paysafe::Error
        message, error_code = parse_error(body)
        klass.new(message: message, code: error_code, response: body)
      end

      private

      def parse_error(body)
        if body.is_a?(Hash)
          [ body.dig(:error, :message), body.dig(:error, :code) ]
        else
          [ '', nil ]
        end
      end
    end

    # The Paysafe API Error Code
    #
    # @return [String]
    attr_reader :code

    # The JSON HTTP response in Hash form
    #
    # @return [Hash]
    attr_reader :response

    # Initializes a new Error object
    #
    # @param message [Exception, String]
    # @param code [String]
    # @param response [Hash]
    # @return [Paysafe::Error]
    def initialize(message: '', code: nil, response: {})
      super(message)
      @code = code
      @response = response
    end
  end
end
