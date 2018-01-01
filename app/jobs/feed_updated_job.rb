# For a subscription, check for new feed items which have been stored. If we
# should send one to the user, send it now.
class FeedUpdatedJob < ApplicationJob
  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)
    subscription.handle_feed_updates
  end
end
