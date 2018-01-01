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

  describe "#fetch" do
    subject(:fetch) { feed.fetch }

    let(:feed_response) { FeedResponse.new(url: feed.url, body: body) }
    let(:body) { File.read("spec/fixtures/feed_response.xml") }

    before do
      allow(feed.fetcher)
        .to receive(:fetch)
        .and_return(feed_response)
    end

    it "fetches the feed and returns a feed response" do
      expect(fetch).to eq(feed_response)
    end
  end

  describe "#fetcher" do
    subject(:fetcher) { feed.fetcher }

    it "returns a fetcher with the URL set" do
      expect(fetcher.url).to eq(feed.url)
    end
  end

  describe "items_since" do
    subject(:items_since) { feed.items_since(item_1) }

    let!(:item_1) { create(:item, feed: feed, published_at: 3.hours.ago) }
    let!(:item_2) { create(:item, feed: feed, published_at: 2.hours.ago) }
    let!(:item_3) { create(:item, feed: feed, published_at: 1.hour.ago) }

    it "returns the items since that item" do
      expect(items_since.count).to eq(2)
      expect(items_since).to eq([item_3, item_2])
    end
  end

  describe "#most_recent_item" do
    subject(:most_recent_item) { feed.most_recent_item }

    context "with items" do
      let!(:older) { create(:feed_item, feed: feed, published_at: 1.day.ago) }
      let!(:newer) { create(:feed_item, feed: feed, published_at: 1.hour.ago) }

      it "returns the most recent item" do
        expect(most_recent_item).to eq(newer)
      end
    end
  end

  describe "#notify_subscriptions_of_updates" do
    let(:subscription) { create(:subscription, feed: feed) }

    it "queues a feed updated job for each subscription" do
      expect(FeedUpdatedJob)
        .to receive(:perform_later)
        .with(subscription.id)

      feed.notify_subscriptions_of_updates
    end
  end
end
