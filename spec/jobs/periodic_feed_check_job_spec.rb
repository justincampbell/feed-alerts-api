require 'rails_helper'

RSpec.describe PeriodicFeedCheckJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    subject(:perform) { job.perform }

    context "with feeds" do
      before do
        create_list :feed, 2
      end

      it "queues a feed check job for each feed having a subscription" do
        expect(FeedCheckJob).to receive(:perform_later).twice

        perform
      end
    end
  end
end
