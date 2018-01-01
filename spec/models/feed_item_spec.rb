require 'rails_helper'

RSpec.describe FeedItem do
  subject(:feed_item) { create(:feed_item) }

  let(:entry) {
    body = File.read("spec/fixtures/feed_response.xml")
    rss = Feedjira::Feed.parse(body)
    rss.entries.first
  }

  it "defaults to showing the newest items first" do
    create(:feed_item, published_at: 2.minutes.ago)
    newer = create(:feed_item, published_at: 1.minute.ago)

    expect(FeedItem.first).to eq(newer)
  end

  describe ".from_feedjira_entry" do
    subject(:feed_item) {
      described_class.from_feedjira_entry(entry, feed: feed)
    }

    let(:feed) { build(:feed) }

    it "sets required attributes" do
      expect(feed_item.feed).to eq(feed)
      expect(feed_item.guid).to eq(entry.id)
      expect(feed_item.title).to eq(entry.title)
      expect(feed_item.content).to eq(entry.content)
    end
  end

  describe "#text" do
    before do
      feed_item.content = entry.content
    end

    it "cleans and returns the entry content" do
      expect(feed_item.text).to eq(
        <<~TEXT
          Back Squat
          1-1-1-1-1
          Then:
          For Time
          30 Wall ball (20/15)
          30 Sumo Deadlift HighPull (75/53)
          30 Box Jump (24/20)
          30 Push Press (75/53)
          300 Meter Run
          20 Wall ball
          20 Sumo Deadlift HighPull
          20 Box Jump
          20 Push Press
          200 Meter run
          10 Wall ball
          10 Sumo Deadlift HighPull
          10 Box Jump
          10 Push Press
          100 meter run
          Post loads and Times to ZEN and Comments:
        TEXT
      )
    end
  end
end
