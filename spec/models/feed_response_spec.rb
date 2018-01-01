require 'rails_helper'

RSpec.describe FeedResponse do
  subject(:feed_response) {
    described_class.new(url: url, body: body, feed: feed)
  }

  let(:feed) { build(:feed) }
  let(:body) { File.read("spec/fixtures/feed_response.xml") }
  let(:url) { "http://crossfitwc.com/category/wod/feed/" }

  describe "#url" do
    subject { feed_response.url }
    it { is_expected.to eq(url) }
  end

  describe "#title" do
    subject(:title) { feed_response.title }
    it { is_expected.to eq("WOD – CrossFit West Chester") }
  end

  describe "#most_recent_item_guid" do
    subject(:most_recent_item_guid) { feed_response.most_recent_item_guid }
    it { is_expected.to eq("http://crossfitwc.com/?p=10206") }
  end

  describe "#most_recent_item" do
    subject(:most_recent_item) { feed_response.most_recent_item }

    it "returns the most recent item" do
      expect(feed_response.items.map(&:guid).max).to eq(most_recent_item.guid)
    end
  end

  describe "items_since" do
    subject(:items_since) { feed_response.items_since(item_guid) }

    let(:item_guid) { "http://crossfitwc.com/?p=10196" }

    it "returns the items since that ID" do
      expect(items_since.count).to eq(2)
    end
  end

  describe "items" do
    subject(:items) { feed_response.items }

    it "returns all items" do
      expect(items.count).to eq(10)
    end

    it "wraps items in a FeedItem" do
      expect(items.map(&:class).uniq).to eq([FeedItem])
    end

    it "sets the feed on each item" do
      expect(items.first.feed).to eq(feed)
    end
  end
end
