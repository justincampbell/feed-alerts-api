require 'rails_helper'

RSpec.describe Subscription do
  subject(:subscription) {
    build(
      :subscription,
      include_feed_name: false,
      include_title: false,
      include_link: false,
      shorten_common_terms: false
    )
  }

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

  it "has sensible defaults" do
    subscription = build(:subscription)

    expect(subscription.include_feed_name).to eq(false)
    expect(subscription.include_title).to eq(true)
    expect(subscription.include_link).to eq(true)
    expect(subscription.shorten_common_terms).to eq(false)
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

    let(:feed) { build(:feed, name: feed_name) }
    let(:item) { build(:item, feed: feed, title: title, content: content) }

    let(:feed_name) { "Greetings Inc." }
    let(:title) { "Hello Everyone!" }
    let(:content) { "<p>hello</p>" }

    it "returns the cleaned item content" do
      expect(render_item).to eq(
        <<~TEXT.strip
          hello
        TEXT
      )
    end

    context "with include_feed_name" do
      before { subscription.include_feed_name = true }

      it "includes the feed name" do
        expect(render_item).to eq(
          <<~TEXT.strip
            Greetings Inc.

            hello
          TEXT
        )
      end
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

      context "with include_feed_name" do
        before { subscription.include_feed_name = true }

        it "includes the feed name" do
          expect(render_item).to eq(
            <<~TEXT.strip
              Greetings Inc.
              Hello Everyone!

              hello
            TEXT
          )
        end

        context "with character_limit" do
          before { subscription.character_limit = 36 }

          it "shortens the message body" do
            expect(render_item).to eq(
              <<~TEXT.strip
                Greetings Inc.
                Hello Everyone!

                hell
              TEXT
            )
          end
        end
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

        context "when title is nil" do
          let(:title) { nil }

          it "omits the item title" do
            expect(render_item).to eq(
              <<~TEXT.strip
                hi
              TEXT
            )
          end
        end
      end
    end

    context "with include_link" do
      before { subscription.include_link = true }

      it "includes the item link" do
        expect(render_item).to eq(
          <<~TEXT.strip
            hello

            #{item.link}
          TEXT
        )
      end
    end
  end
end
