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
    response = fetcher.fetch
    response.validate
    record_event "fetch"
    response
  rescue StandardError => error
    unless detail = HANDLED_ERRORS[error.class]
      Raven.capture_exception error
      detail = "Unknown error"
    end

    record_event "fetch", detail: detail, error: true

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

  private

  def record_event(event, detail: nil, error: false)
    return unless persisted?

    Event.record event,
      resource: self,
      detail: detail,
      error: error
  end
end
