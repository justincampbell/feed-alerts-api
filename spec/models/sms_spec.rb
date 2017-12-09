require 'rails_helper'

RSpec.describe SMS do
  subject(:sms) { described_class.new }

  describe "#handle_message" do
    subject(:handle_message) { sms.handle_message(from, body) }

    let(:from) { user.sms_number }
    let(:user) { create(:user) }

    context "help" do
      let(:body) { "help" }

      it "responds with help" do
        reply = handle_message
        expect(reply).to include("STOP to cancel all subscriptions")
      end
    end

    context "stop" do
      let(:body) { "stop" }

      context "without subscriptions" do
        it "replies with an error message" do
          reply = handle_message
          expect(reply).to eq("You are not currently subscribed to any feeds.")
        end
      end

      context "with subscriptions" do
        before { create_list :subscription, 2, user: user }

        it "deletes all subscriptions for this user" do
          reply = handle_message
          expect(reply).to eq("You have been unsubscribed.")
          expect(user.subscriptions.count).to eq(0)
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
          expect(reply).to eq("You have 2 subscription(s).")
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
