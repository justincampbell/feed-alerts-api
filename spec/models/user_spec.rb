require 'rails_helper'

RSpec.describe User do
  subject(:user) { build(:user, sms_number: sms_number) }

  let(:sms_number) { Faker::PhoneNumber.cell_phone }

  describe "#sms_number" do
    it "sanitizes the number" do
      user.sms_number = "(234) 567-8900"
      expect(user.sms_number).to eq("+12345678900")
    end

    context "when nil" do
      let(:sms_number) { nil }
      it { is_expected.to_not be_valid }
    end

    context "when empty" do
      let(:sms_number) { " " }
      it { is_expected.to_not be_valid }
    end

    context "when invalid" do
      let(:sms_number) { "notanumber" }
      it { is_expected.to_not be_valid }
    end

    generative "with random fake cell numbers" do
      data(:sms_number) { Faker::PhoneNumber.cell_phone }

      it "is valid" do
        expect(user).to be_valid
      end
    end
  end

  describe "#deliver_message" do
    subject(:deliver_message) { user.deliver_message(body) }

    let(:body) { "hello" }

    it "sends an SMS" do
      expect_any_instance_of(SMS)
        .to receive(:send)
        .with(user.sms_number, body)

      deliver_message
    end
  end
end
