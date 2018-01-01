class PeriodicFeedCheckJob < ApplicationJob
  def perform
    Feed.joins(:subscriptions).pluck(:id).uniq.each do |feed_id|
      FeedCheckJob.perform_later feed_id
    end
  end
end
