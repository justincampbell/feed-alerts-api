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

  it "validates kind" do
    feed.kind = nil
    expect(feed).to be_valid
    feed.kind = "rss"
    expect(feed).to be_valid
    feed.kind = "foobar"
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

    it "fetches the feed, validates, and returns a feed response" do
      expect(feed_response).to receive(:validate)
      expect(fetch).to eq(feed_response)
    end

    {
      Errno::ECONNREFUSED => /could not connect/i,
      Feedjira::NoParserAvailable => /could not parse/i,
      Net::OpenTimeout => /timeout/i,
    }.each do |error_class, detail_regexp|
      context "when #{error_class} is raised" do
        before do
          feed.save!

          allow(feed.fetcher)
            .to receive(:fetch)
            .and_raise(error_class)
        end

        it "records an event and raises a FeedFetchError" do
          expect {
            expect {
              fetch
            }.to raise_error(FeedFetchError, detail_regexp)
          }.to change { Event.count }.by(1)

          event = Event.last
          expect(event.resource).to eq(feed)
          expect(event.detail).to match(detail_regexp)
        end
      end
    end

    context "when not a handled error" do
      let(:error) { StandardError.new }

      before do
        allow(feed.fetcher)
          .to receive(:fetch)
          .and_raise(error)
      end

      it "reports to Sentry" do
        expect(Raven).to receive(:capture_exception).with(error)
        expect { fetch }.to raise_error(FeedFetchError, /unknown/i)
      end
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
