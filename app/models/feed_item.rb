class FeedItem
  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def id
    entry.id
  end

  def title
    entry.title
  end

  def text
    @text ||= Cleaner.clean(entry.content)
  end
end
