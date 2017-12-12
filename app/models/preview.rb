require 'securerandom'

class Preview
  attr_reader :feed_response
  attr_reader :subscription
  attr_reader :replacer

  def initialize(feed_response, subscription: nil, replacer: nil)
    @feed_response = feed_response
    @subscription = subscription
    @replacer = replacer
  end

  def id
    @id ||= SecureRandom.uuid
  end

  def text
    item = feed_response.most_recent_item
    parts = []

    if subscription.include_title?
      parts << item.title
    end

    parts << item.text

    text = parts.compact.join("\n")

    if subscription.shorten_common_terms?
      text = replacer.replace(text)
    end

    text
  end
end
