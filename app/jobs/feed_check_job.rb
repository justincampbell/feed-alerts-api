class FeedCheckJob < ApplicationJob
  def perform(feed_id)
    feed = Feed.find(feed_id)
    feed_response = feed.fetch

    saved = feed_response.items.map(&:save)

    if saved.any?
      feed.notify_subscriptions_of_updates
    end
  end
end
