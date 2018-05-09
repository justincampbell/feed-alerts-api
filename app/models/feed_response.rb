class FeedResponse
  attr_reader :body
  attr_reader :feed
  attr_reader :url

  # TODO: Can url be removed? It doesn't seem to be used.
  def initialize(body: , feed: nil, url: )
    @body = body
    @feed = feed
    @url = url
  end

  def title
    rss.title
  end

  def most_recent_item_guid
    most_recent_item.guid
  end

  def most_recent_item
    @most_recent_item ||= items.first
  end

  def items_since(item_guid)
    items.take_while { |item| item.guid != item_guid }
  end

  def items
    @items ||= rss.entries.map { |entry|
      FeedItem.from_feedjira_entry(entry, feed: feed)
    }
  end

  def validate
    items
    most_recent_item
    title
  end

  private

  def rss
    @rss ||= Feedjira::Feed.parse(body)
  end
end
