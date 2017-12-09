class AuthenticatesController < ApplicationController
  def show
    if current_user
      render jsonapi: current_user
    else
      render_jsonapi_error 404, "Not found"
    end
  end

  def destroy
    return unless current_session
    current_session.destroy!
  end

  def request_code
    code = VerificationCode.store(sms_number)
    text = "#{code} is your verification code"
    SMS.new.send sms_number, text
    head :accepted
  end

  def create
    verification_code = authentication_params[:verification_code]

    unless VerificationCode.verify(sms_number, verification_code)
      render_jsonapi_error 403, "Invalid verification code"
      return
    end

    user = User.find_or_create_by(sms_number: sms_number)
    session = user.sessions.create

    render jsonapi: session,
      status: :created
  end

  private

  def authentication_params
    params.permit(:sms_number, :verification_code)
  end

  def sms_number
    SMS.normalize(authentication_params[:sms_number])
  end
end
