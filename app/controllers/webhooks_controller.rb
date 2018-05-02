class WebhooksController < ApplicationController
  def twilio
    body = params['Body']
    from = params['From']

    Event.record "sms-received",
      sms_number: from,
      detail: body

    if reply = SMS.new.handle_message(from, body)
      response = Twilio::TwiML::MessagingResponse.new
      response.message body: reply

      render xml: response.to_xml

      Event.record "sms-sent",
        sms_number: from,
        detail: reply
    else
      head :no_content
    end
  end
end
