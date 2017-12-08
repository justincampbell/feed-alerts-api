require 'rails_helper'

RSpec.describe VerificationCode do
  let(:destination) { "1234567890" }

  describe ".store" do
    it "generates a string and stores it with a destination" do
      code = VerificationCode.store(destination)
      expect(VerificationCode.verify(destination, code)).to eq(true)
    end
  end

  describe ".verify" do
    subject(:verify) { VerificationCode.verify(destination, code) }

    context "with an existing verification code" do
      let(:code) { VerificationCode.store(destination) }
      it { is_expected.to eq(true) }
    end

    context "with a nonexistant code" do
      let(:code) { VerificationCode.generate }
      it { is_expected.to eq(false) }
    end

    context "with no code" do
      let(:code) { nil }
      it { is_expected.to eq(false) }
    end
  end
end
