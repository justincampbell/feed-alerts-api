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
    lines = []

    if include_feed_name?
      lines << item.feed.name
    end

    if include_title?
      lines << shorten(item.title)
      lines << ""
    end

    lines << shorten(item.text)

    if include_link?
      lines << ""
      lines << item.link
    end

    text = lines.compact.join("\n")

    text.gsub(/\n\n+/, "\n\n").strip
  end

  def shorten(text)
    return text unless shorten_common_terms?
    replacer.replace(text)
  end
end
