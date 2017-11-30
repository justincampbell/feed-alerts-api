require 'rails_helper'

RSpec.describe User do
  subject(:user) { build(:user, sms_number: sms_number) }

  let(:sms_number) { Faker::PhoneNumber.cell_phone }

  describe "#sms_number" do
    it "sanitizes the number" do
      user.sms_number = "(123) 456-7890"
      expect(user.sms_number).to eq("1234567890")
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
end
