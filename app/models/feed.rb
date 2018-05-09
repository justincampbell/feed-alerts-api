class FeedFetchError < StandardError
end

class Feed < ApplicationRecord
  HANDLED_ERRORS = {
    Errno::ECONNREFUSED => "Could not connect to URL",
    Feedjira::NoParserAvailable => "Could not parse feed",
    Net::OpenTimeout => "Timeout while fetching feed",
  }

  belongs_to :created_by,
    class_name: "User",
    required: false

  has_many :items,
    class_name: "FeedItem",
    dependent: :destroy

  has_many :subscriptions,
    dependent: :destroy

  validates :kind,
    inclusion: { in: %w[rss] },
    allow_nil: true

  validates :name,
    presence: true

  validates :url,
    presence: true,
    uniqueness: true,
    url: true

  def fetch
    fetcher.fetch.tap(&:validate)
  rescue StandardError => error
    unless detail = HANDLED_ERRORS[error.class]
      Raven.capture_exception error
      detail = "Unknown error"
    end

    if persisted?
      Event.record "fetch",
        resource: self,
        detail: detail,
        error: true
    end

    raise FeedFetchError.new(detail)
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
