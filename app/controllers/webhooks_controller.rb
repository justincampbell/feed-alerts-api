class WebhooksController < ApplicationController
  def twilio
    body = params['Body']
    from = params['From']

    if reply = SMS.new.handle_message(from, body)
      response = Twilio::TwiML::MessagingResponse.new
      response.message body: reply

      render xml: response.to_xml
    else
      head :no_content
    end
  end
end
