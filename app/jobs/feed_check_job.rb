class FeedCheckJob < ApplicationJob
  def perform(feed_id)
    feed = Feed.find(feed_id)

    begin
      feed_response = feed.fetch
    rescue Feedjira::NoParserAvailable => error
      Rails.logger.error error
      return
      # TODO: Track feed errors in DB
    end

    saved = feed_response.items.map(&:save)

    if saved.any?
      feed.notify_subscriptions_of_updates
    end
  end
end
