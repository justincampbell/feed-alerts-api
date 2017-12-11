require 'securerandom'

class Preview
  attr_reader :feed_response
  attr_reader :subscription

  def initialize(feed_response, subscription: nil)
    @feed_response = feed_response
    @subscription = subscription
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

    parts.compact.join("\n")
  end
end
