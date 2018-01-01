require 'rails_helper'

RSpec.describe FeedUpdatedJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    subject(:perform) { job.perform(subscription.id) }

    let(:subscription) { create(:subscription) }

    before do
      allow(Subscription)
        .to receive(:find)
        .with(subscription.id)
        .and_return(subscription)
    end

    it "calls the feed handler for the subscription" do
      expect(subscription).to receive(:handle_feed_updates)
      perform
    end
  end
end
