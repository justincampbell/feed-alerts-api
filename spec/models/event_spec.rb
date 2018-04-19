require 'rails_helper'

RSpec.describe Event do
  subject(:event) {  build(:event) }

  it "validates the event code" do
    event.code = described_class::VALID_CODES.sample
    expect(event).to be_valid
    event.code = "foobar"
    expect(event).to_not be_valid
  end
end
