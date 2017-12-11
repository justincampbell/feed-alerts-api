require 'rails_helper'

RSpec.describe Preview do
  subject(:preview) {
    described_class.new(feed_response, subscription: subscription)
  }

  let(:feed_response) { double(FeedResponse, most_recent_item: feed_item) }
  let(:subscription) { build(:subscription) }

  let(:feed_item) { double(FeedItem, title: "item title", text: "item text") }

  describe "#id" do
    it "is a UUID" do
      expect(preview.id).to match(/\A(\h{32}|\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\z/)
    end

    it "is memoized" do
      expect(preview.id).to eq(preview.id)
    end

    it "is random" do
      expect(preview.id).to_not eq(Preview.new(nil).id)
    end
  end

  describe "#text" do
    subject(:text) { preview.text }

    it "returns the most recent item's text" do
      expect(text).to eq("item text")
    end

    context "when the subscription includes the title" do
      before { subscription.include_title = true }

      it "prepends the title" do
        expect(text).to eq(
          <<~TEXT.strip
            item title
            item text
          TEXT
        )
      end
    end
  end
end
