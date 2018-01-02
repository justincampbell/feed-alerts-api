class ApplicationController < ActionController::API
  AUTHORIZATION_BEARER_PREFIX= /^Bearer\s/

  before_action :set_raven_context

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

  private

  def set_raven_context
    if current_user
      Raven.user_context(
        id: current_user.id
      )
    end

    Raven.extra_context(
      params: params.to_unsafe_h,
      url: request.url
    )
  end
end
