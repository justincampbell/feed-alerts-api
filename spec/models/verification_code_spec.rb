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
      let!(:code) { VerificationCode.store(destination) }
      it { is_expected.to eq(true) }

      it "deletes the code" do
        expect {
          verify
        }.to change { VerificationCode.count }.by(-1)
      end
    end

    context "with a nonexistant code" do
      let!(:code) { VerificationCode.generate }
      it { is_expected.to eq(false) }

      it "deletes expired codes" do
        old = VerificationCode.find_by(code: VerificationCode.store(destination))
        old.update! created_at: 10.minutes.ago
        new = VerificationCode.find_by(code: VerificationCode.store(destination))

        expect {
          verify
        }.to change { VerificationCode.count }.by(-1)

        expect { old.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(new.reload).to be_persisted
      end
    end

    context "with no code" do
      let(:code) { nil }
      it { is_expected.to eq(false) }
    end
  end
end
