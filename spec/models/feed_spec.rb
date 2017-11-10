require 'rails_helper'

RSpec.describe Feed do
  subject(:feed) { build(:feed) }

  it "is valid" do
    expect(feed).to be_valid
  end

  it "valides presence of name" do
    feed.name = nil
    expect(feed).to_not be_valid
  end

  describe "#url" do
    context "when nil" do
      before { feed.url = nil }
      it { is_expected.to_not be_valid }
    end

    context "when not a valid URL" do
      before { feed.url = "foo bar" }
      it { is_expected.to_not be_valid }
    end
  end
end
