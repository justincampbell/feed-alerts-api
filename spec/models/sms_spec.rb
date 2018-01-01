require 'rails_helper'

RSpec.describe SMS do
  subject(:sms) { described_class.new }

  describe ".normalize" do
    it "passes through nil" do
      expect(SMS.normalize(nil)).to eq(nil)
    end

    it "normalizes a number" do
      expect(SMS.normalize("2345678900")).to eq("+12345678900")
      expect(SMS.normalize("(234) 567-8900")).to eq("+12345678900")
      expect(SMS.normalize("+1 (234) 567-8900")).to eq("+12345678900")
    end

    it "special cases normalized numbers starting with +1" do
      expect(SMS.normalize("1234567890")).to eq("+11234567890")
    end
  end

  describe "#handle_message" do
    subject(:handle_message) { sms.handle_message(from, body) }

    let(:from) { user.sms_number }
    let(:user) { create(:user) }

    context "cancel, stop" do
      let(:body) { "stop" }

      it "does not respond" do
        reply = handle_message
        expect(reply).to eq(nil)
      end

      context "with subscriptions" do
        before { create_list :subscription, 2, user: user }

        it "deletes all subscriptions for this user" do
          reply = handle_message
          expect(reply).to eq(nil)
          expect(user.subscriptions.count).to eq(0)
        end
      end

      context "without a matching user" do
        let(:from) { Faker::PhoneNumber.cell_phone }

        it "does not respond" do
          reply = handle_message
          expect(reply).to eq(nil)
        end
      end
    end

    context "subscriptions" do
      let(:body) { "subscriptions" }

      context "without subscriptions" do
        it "replies with an error message" do
          reply = handle_message
          expect(reply).to eq("You are not currently subscribed to any feeds.")
        end
      end

      context "with subscriptions" do
        before { create_list :subscription, 2, user: user }

        it "replies with the subscription count" do
          reply = handle_message
          expect(reply.lines.first.strip).to eq("You have 2 subscriptions:")
        end
      end
    end
  end

  describe "#send" do
    subject(:send) { sms.send to, body }

    let(:to) { "2345678900" }
    let(:body) { "hello" }

    it "sends an SMS" do
      expect(sms.client)
        .to receive_message_chain(:api, :account, :messages, :create)
        .with(from: sms.from, to: to, body: body)

      send
    end
  end

  describe "#client" do
    subject(:client) { sms.client }

    it { is_expected.to be_a(Twilio::REST::Client) }
  end
end
