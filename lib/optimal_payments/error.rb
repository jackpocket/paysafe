module OptimalPayments
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
      400 => OptimalPayments::Error::BadRequest,
      401 => OptimalPayments::Error::Unauthorized,
      402 => OptimalPayments::Error::RequestDeclined,
      403 => OptimalPayments::Error::Forbidden,
      404 => OptimalPayments::Error::NotFound,
      406 => OptimalPayments::Error::NotAcceptable,
      409 => OptimalPayments::Error::Conflict,
      415 => OptimalPayments::Error::UnsupportedMediaType,
      422 => OptimalPayments::Error::UnprocessableEntity,
      429 => OptimalPayments::Error::TooManyRequests,
      500 => OptimalPayments::Error::InternalServerError,
      502 => OptimalPayments::Error::BadGateway,
      503 => OptimalPayments::Error::ServiceUnavailable,
      504 => OptimalPayments::Error::GatewayTimeout,
    }

    # @return [Integer]
    attr_reader :code

    # @return [Hash]
    attr_reader :response

    class << self
      # Create a new error from an HTTP response
      #
      # @param body [String]
      # @param code [Integer]
      # @return [OptimalPayments::Error]
      def error_from_response(body, code)
        klass = ERRORS[code] || OptimalPayments::Error
        message = parse_error(body)
        klass.new(message, code, body)
      end

    private

      def parse_error(body)
        default_message = 'An unknown error has occurred.'
        if body.is_a?(Hash) && body[:error].is_a?(Hash)
          body[:error][:message] || default_message
        else
          default_message
        end
      end

    end

    # Initializes a new Error object
    #
    # @param message [Exception, String]
    # @param code [Integer]
    # @param response [Hash]
    # @return [OptimalPayments::Error]
    def initialize(message = '', code = nil, response = {})
      super(message)
      @code = code
      @response = response
    end
  end
end