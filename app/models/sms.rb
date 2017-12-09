class SMS
  def self.normalize(number)
    Phonelib.parse(number).e164
  end

  def handle_message(from, body)
    user = User.find_by(sms_number: from)

    case body.downcase.strip
    when "ping"
      "pong"
    when "start"
      "Welcome back! TODO go to URL to add a new subscription"
    when "cancel", "stop"
      user.subscriptions.destroy_all if user
      nil
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
