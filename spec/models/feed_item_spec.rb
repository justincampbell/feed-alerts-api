require 'rails_helper'

RSpec.describe FeedItem do
  subject(:feed_item) { described_class.new(entry) }

  let(:entry) {
    body = File.read("spec/fixtures/feed_response.xml")
    rss = Feedjira::Feed.parse(body)
    rss.entries.first
  }

  %w[
    id
    title
  ].each do |method_name|
    describe "##{method_name}" do
      it "delegates to the entry" do
        expect(feed_item.public_send(method_name))
          .to eq(entry.public_send(method_name))
      end
    end
  end

  describe "#text" do
    subject(:text) { feed_item.text }

    it "cleans and returns the entry content" do
      expect(text).to eq(
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
