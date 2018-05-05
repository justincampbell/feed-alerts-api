require 'rails_helper'

RSpec.describe Event do
  subject(:event) {  build(:event) }

  it "validates the event code" do
    event.code = described_class::VALID_CODES.sample
    expect(event).to be_valid
    event.code = "foobar"
    expect(event).to_not be_valid
  end

  describe ".record" do
    let(:code) { "sms-sent" }
    let(:sms_number) { Faker::PhoneNumber.cell_phone }
    let(:user) { create(:user) }

    it "creates an event and assigns the attributes" do
      event = described_class.record(
        code,
        resource: user,
        detail: "detail",
        data: { abc: 123 }
      )

      event.reload

      expect(event.resource).to eq(user)
      expect(event.detail).to eq("detail")
      expect(event.data).to eq({ "abc" => 123 })
    end

    context "with an sms_number" do
      it "creates a user" do
        expect {
          described_class.record(code, sms_number: sms_number)
        }.to change { User.count }.by(1)
      end
    end

    context "with neither a resource nor sms_number" do
      it "raises an error" do
        expect {
          described_class.record(code)
        }.to raise_error(/Must pass/)
      end
    end
  end
end
