require 'rails_helper'

RSpec.describe Subscription do
  subject(:subscription) { build(:subscription) }

  let(:feed) { subscription.feed }
  let(:user) { subscription.user }

  let(:replacer) {
    Class.new {
      def replace(text)
        text.gsub(/(h)ello/i, '\1i')
      end
    }.new
  }

  before { allow(subscription).to receive(:replacer).and_return(replacer) }

  it "does not allow duplicate subscriptions for the same user" do
    subscription.save

    new_subscription = Subscription.new(
      feed: subscription.feed,
      user: subscription.user
    )

    expect(new_subscription).to_not be_valid
    expect(new_subscription.errors[:feed])
      .to include("already subscribed to")
  end

  describe "#include_title" do
    subject(:include_title) { subscription.include_title }

    it "defaults to false" do
      expect(include_title).to eq(false)
    end
  end

  describe "#shorten_common_terms" do
    subject(:shorten_common_terms) { subscription.shorten_common_terms }

    it "defaults to false" do
      expect(shorten_common_terms).to eq(false)
    end
  end

  describe "#preview" do
    subject(:preview) { subscription.preview(item) }

    let(:item) { build(:item, content: text) }
    let(:text) { "text" }

    it "returns a preview object" do
      expect(preview).to be_a(Preview)
      expect(preview.text).to eq(text)
    end
  end

  describe "#handle_feed_updates" do
    subject(:handle_feed_updates) { subscription.handle_feed_updates }

    before { allow(user).to receive(:deliver_message) }

    context "with no feed items" do
      it "sends nothing to the user" do
        expect(user).to_not receive(:deliver_message)
        handle_feed_updates
      end
    end

    context "with feed items" do
      let!(:item) {
        create(
          :item,
          feed: feed,
          title: title,
          content: content,
          published_at: 1.hour.ago
        )
      }

      let(:content) { "hello" }
      let(:title) { "hello everyone" }

      it "sends the latest feed item to the user" do
        expect(user).to receive(:deliver_message).with(content)

        handle_feed_updates
      end

      context "with subscription options" do
        before do
          subscription.include_title = true
          subscription.shorten_common_terms = true
        end

        it "formats the feed item" do
          expect(user).to receive(:deliver_message).with(
            <<~BODY.strip
              hi everyone

              hi
            BODY
          )

          handle_feed_updates
        end
      end

      it "updates the last_sent_item" do
        expect { handle_feed_updates }
          .to change { subscription.last_sent_item }
          .from(nil)
          .to(item)
      end

      context "when the latest item was already sent" do
        before { subscription.update! last_sent_item: item }

        it "does not send it again" do
          expect(user).to_not receive(:deliver_message)
          handle_feed_updates
        end
      end

      context "when there are multiple items since the last one sent" do
        before do
          create :item, feed: feed, content: "again", published_at: 2.hours.ago
        end

        it "only sends the latest one" do
          expect(user).to receive(:deliver_message).with(content)
          expect(user).to_not receive(:deliver_message).with("again")
          handle_feed_updates
        end
      end
    end
  end

  describe "#render_item" do
    subject(:render_item) { subscription.render_item(item) }

    let(:item) { build(:item, title: title, content: content) }

    let(:title) { "Hello Everyone!" }
    let(:content) { "<p>hello</p>" }

    it "returns the cleaned item content" do
      expect(render_item).to eq(
        <<~TEXT.strip
          hello
        TEXT
      )
    end

    context "with include_title" do
      before { subscription.include_title = true }

      it "includes the item title" do
        expect(render_item).to eq(
          <<~TEXT.strip
            Hello Everyone!

            hello
          TEXT
        )
      end

    context "with shorten_common_terms" do
      before do
        subscription.shorten_common_terms = true
      end

      it "shortens the text according to the replacer" do
        expect(render_item).to eq(
          <<~TEXT.strip
            Hi Everyone!

            hi
          TEXT
        )
      end
    end
    end
  end
end
