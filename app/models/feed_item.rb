class FeedItem < ApplicationRecord
  belongs_to :feed

  validates_uniqueness_of :guid,
    scope: :feed

  default_scope { order(published_at: :desc) }

  def self.from_feedjira_entry(entry, feed: nil)
    new(
      feed: feed,
      guid: entry.id,
      title: entry.title,
      content: entry.content
    )
  end

  def text
    @text ||= Cleaner.clean(content)
  end
end
