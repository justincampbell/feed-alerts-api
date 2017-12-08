require 'rails_helper'

RSpec.describe Subscription do
  subject(:subscription) { build(:subscription) }

  it "does not allow duplicate subscriptions for the same user" do
    subscription.save

    new_subscription = Subscription.new(
      feed: subscription.feed,
      user: subscription.user
    )

    expect(new_subscription).to_not be_valid
    expect(new_subscription.errors[:feed])
      .to include("already subscribed to")
  end

  describe "#include_title" do
    subject(:include_title) { subscription.include_title }

    it "defaults to false" do
      expect(include_title).to eq(false)
    end
  end

  describe "#shorten_common_terms" do
    subject(:shorten_common_terms) { subscription.shorten_common_terms }

    it "defaults to false" do
      expect(shorten_common_terms).to eq(false)
    end
  end
end