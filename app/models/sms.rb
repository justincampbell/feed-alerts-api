class SMS
  include ActionView::Helpers::TextHelper

  def self.normalize(number)
    result = Phonelib.parse(number).e164

    return unless result

    # If Phonelib parses a number starting with 1, it assume it's a country
    # code and returns an invalid number.
    if result.start_with?("+1") && result.length == 11
      result.gsub!(/^\+1/, "+11")
    end

    result
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
        "You have #{pluralize(user.subscriptions.count, "subscription")}:\n" +
          user.subscriptions.map(&:feed).map(&:name).join("\n")
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
