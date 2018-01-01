class Subscription < ApplicationRecord
  belongs_to :user

  belongs_to :feed

  belongs_to :last_sent_item,
    class_name: "FeedItem",
    required: false

  validates :feed,
    uniqueness: { scope: :user, message: "already subscribed to" }

  def preview(item)
    text = render_item(item)
    Preview.new(text)
  end

  def replacer
    Replacer.new
  end

  def handle_feed_updates
    item = feed.most_recent_item
    unless item == last_sent_item
      text = render_item(item)
      user.deliver_message text
      update! last_sent_item: item
    end
  end

  def render_item(item)
    parts = []

    if include_title?
      parts << item.title
    end

    parts << item.text

    text = parts.compact.join("\n")

    if shorten_common_terms?
      text = replacer.replace(text)
    end

    text.strip
  end
end
