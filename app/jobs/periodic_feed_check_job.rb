class PeriodicFeedCheckJob < ApplicationJob
  def perform
    Feed.pluck(:id).each do |feed_id|
      FeedCheckJob.perform_later feed_id
    end
  end
end
