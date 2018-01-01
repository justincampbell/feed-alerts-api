require 'rails_helper'

RSpec.describe PeriodicFeedCheckJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    subject(:perform) { job.perform }

    context "with subscriptions" do
      let(:feed_a) { create(:feed) }
      let(:feed_b) { create(:feed) }

      before do
        create :subscription, feed: feed_a
        create :subscription, feed: feed_a
        create :subscription, feed: feed_b
      end

      it "queues a feed check job for each feed having a subscription" do
        expect(FeedCheckJob).to receive(:perform_later).with(feed_a.id).once
        expect(FeedCheckJob).to receive(:perform_later).with(feed_b.id).once

        perform
      end
    end
  end
end
