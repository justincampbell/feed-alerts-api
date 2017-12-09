class SMS
  def handle_message(from, body)
    user = User.find_by(sms_number: from)

    case body.downcase.strip
    when "ping"
      "pong"
    when "stop"
      if user.subscriptions.any?
        user.subscriptions.destroy_all
        "You have been unsubscribed."
      else
        "You are not currently subscribed to any feeds."
      end
    when "subscriptions"
      if user.subscriptions.any?
        "You have #{user.subscriptions.count} subscription(s)."
      else
        "You are not currently subscribed to any feeds."
      end
    else
      "STOP to cancel all subscriptions."
    end
  end

  def send(to, body)
    Rails.logger.info "[SMS] sending to #{to} #{body.inspect}"
    client.api.account.messages.create(from: from, to: to, body: body)
  end

  def client
    @client ||= Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end

  def from
    ENV['TWILIO_FROM_NUMBER']
  end
end
