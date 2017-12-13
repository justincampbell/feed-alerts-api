class FeedResponse
  attr_reader :url
  attr_reader :body

  def initialize(url: , body: )
    @url = url
    @body = body
  end

  def title
    rss.title
  end

  def most_recent_item_id
    most_recent_item.id
  end

  def most_recent_item
    items.first
  end

  def items_since(item_id)
    items.take_while { |item| item.id != item_id }
  end

  def items
    rss.entries.map { |entry| FeedItem.new(entry) }
  end

  private

  def rss
    @rss ||= Feedjira::Feed.parse(body)
  end
end
