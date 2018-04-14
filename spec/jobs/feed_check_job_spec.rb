require 'rails_helper'

RSpec.describe FeedCheckJob do
  subject(:job) { described_class.new }

  describe "#perform" do
    subject(:perform) { job.perform(feed_id) }

    let(:feed_id) { feed.id }
    let(:feed) { create(:feed) }
    let(:body) { File.read("spec/fixtures/feed_response.xml") }

    before do
      allow(Net::HTTP)
        .to receive(:get_response)
        .with(URI(feed.url))
        .and_return(double(Net::HTTPResponse, body: body))
    end

    it "stores each item" do
      expect { perform }.to change { feed.items.count }.by(10)
    end

    it "does not store duplicates" do
      job.perform feed_id
      FeedItem.first.destroy

      expect {
        job.perform feed_id
      }.to change { FeedItem.count }.by(1)
    end

    context "with subscriptions" do
      let(:subscription) { create(:subscription, feed: feed) }

      it "notifies each subscription if the feed had updates" do
        expect(FeedUpdatedJob)
          .to receive(:perform_later)
          .with(subscription.id)

        job.perform feed_id
      end
    end

    context "with a no parser error during fetch" do
      before do
        allow_any_instance_of(Feed)
          .to receive(:fetch)
          .and_raise(Feedjira::NoParserAvailable)
      end

      it "just returns" do
        job.perform feed_id
      end
    end

    context "with a no parser error during items" do
      before do
        allow_any_instance_of(FeedResponse)
          .to receive(:items)
          .and_raise(Feedjira::NoParserAvailable)
      end

      it "just returns" do
        job.perform feed_id
      end
    end
  end
end
