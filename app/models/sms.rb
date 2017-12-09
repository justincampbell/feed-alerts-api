class SMS
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
