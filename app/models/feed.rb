class Feed < ApplicationRecord
  belongs_to :created_by,
    class_name: "User",
    required: false

  has_many :items,
    class_name: "FeedItem",
    dependent: :destroy

  has_many :subscriptions,
    dependent: :destroy

  validates :name,
    presence: true

  validates :url,
    presence: true,
    url: true

  def fetch
    fetcher.fetch
  end

  def fetcher
    @fetcher ||= Fetcher.new(feed: self, url: url)
  end

  def most_recent_item
    items.first
  end

  def items_since(item)
    items.where("published_at > ?", item.published_at)
  end

  def notify_subscriptions_of_updates
    subscriptions.each do |subscription|
      FeedUpdatedJob.perform_later subscription.id
    end
  end
end
