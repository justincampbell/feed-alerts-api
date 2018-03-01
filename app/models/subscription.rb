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
    result = _render_item(item)

    trim = 0
    until result.length <= character_limit
      result = _render_item(item, trim += 1)
    end

    result
  end

  def _render_item(item, trim = 0)
    lines = []

    if include_feed_name?
      lines << item.feed.name
    end

    if include_title?
      lines << shorten(item.title)
    end

    lines << ""

    text = shorten(item.text)
    text_size = text.length - trim
    if text_size.nonzero?
      lines << text[0, text_size]
    else
      raise "Never found a string that would fit"
    end

    if include_link?
      lines << ""
      lines << item.link
    end

    text = lines.compact.join("\n")

    text.gsub(/\n\n+/, "\n\n").strip
  end

  def shorten(text)
    return unless text
    return text unless shorten_common_terms?
    replacer.replace(text)
  end
end
