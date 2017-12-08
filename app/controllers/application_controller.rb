class ApplicationController < ActionController::API
  AUTHORIZATION_BEARER_PREFIX= /^Bearer\s/

  def current_session
    return unless token
    Session.find_by(token: token)
  end

  def current_user
    return unless current_session
    current_session.user
  end

  def token
    authorization_header = request.headers['Authorization']
    return unless authorization_header
    return unless authorization_header.match(AUTHORIZATION_BEARER_PREFIX)
    authorization_header.gsub(AUTHORIZATION_BEARER_PREFIX, '')
  end

  def render_jsonapi_error(status, title, detail = nil)
    detail ||= title

    json = {
      errors: [
        {
          status: status,
          title: title,
          detail: detail
        }
      ]
    }

    render json: json, status: status
  end
end
