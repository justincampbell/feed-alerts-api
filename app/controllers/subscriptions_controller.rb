class SubscriptionsController < ApplicationController
  def create
    unless current_user
      render_jsonapi_error 403, "Forbidden"
      return
    end

    subscription = Subscription.new(create_params)
    subscription.user = current_user

    if subscription.save
      render jsonapi: subscription,
        include: [:feed],
        status: :created
    else
      render jsonapi_errors: subscription.errors,
        status: :forbidden
    end
  end

  def preview
    subscription = Subscription.new(create_params)
    feed = subscription.feed
    item = feed.most_recent_item

    if item
      render jsonapi: subscription.preview(item)
    else
      render_jsonapi_error 404, "Not found"
    end
  end

  private

  def create_params
    jsonapi_params.permit(
      :feed_id,
      :include_feed_name,
      :include_title,
      :include_link,
      :shorten_common_terms
    )
  end
end
