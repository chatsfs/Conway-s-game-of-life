module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from GameError, with: :unprocessable_entity_with_message
    rescue_from GameTimeoutError, with: :request_timeout
  end

  private

  def not_found(exception = nil)
    logger.error "Not found: #{exception&.message}"
    render json: error_response("Resource not found", :not_found),
           status: :not_found
  end

  def unprocessable_entity(exception)
    logger.error "Validation failed: #{exception.message}"
    errors = exception.record.errors.full_messages
    render json: error_response("Validation failed", :unprocessable_content, errors),
           status: :unprocessable_content
  end

  def bad_request(exception)
    logger.error "Bad request: #{exception.message}"
    render json: error_response(exception.message, :bad_request),
           status: :bad_request
  end

  def unprocessable_entity_with_message(exception)
    logger.error "Game error: #{exception.message}"
    render json: error_response(exception.message, :unprocessable_content),
           status: :unprocessable_content
  end

  def request_timeout(exception)
    logger.error "Request timeout: #{exception.message}"
    render json: error_response(exception.message, :request_timeout),
           status: :request_timeout
  end

  def error_response(message, code, details = nil)
    response = {
      error: {
        message: message,
        code: code,
        timestamp: Time.current.iso8601
      }
    }
    response[:error][:details] = details if details.present?
    response
  end
end
