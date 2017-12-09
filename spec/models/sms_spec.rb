require 'rails_helper'

RSpec.describe SMS do
  subject(:sms) { described_class.new }

  describe "#send" do
    subject(:send) { sms.send to, text }

    let(:to) { "1234567890" }
    let(:text) { "hello" }

    it "sends an SMS" do
      expect(sms.client)
        .to receive_message_chain(:api, :account, :messages, :create)
        .with(from: sms.from, to: to, body: text)

      send
    end
  end

  describe "#client" do
    subject(:client) { sms.client }

    it { is_expected.to be_a(Twilio::REST::Client) }
  end
end
