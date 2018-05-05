class SubscriptionsController < ApplicationController
  def create
    unless current_user
      render_jsonapi_error 403, "Forbidden"
      return
    end

    subscription = Subscription.new(create_params)
    subscription.user = current_user

    if subscription.save
      Event.record "subscription-created",
        resource: current_user,
        data: create_params

      render jsonapi: subscription,
        include: [:feed],
        status: :created
    else
      Event.record "error",
        resource: current_user,
        detail: subscription.errors.full_messages.to_sentence,
        data: create_params

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
      :character_limit,
      :include_feed_name,
      :include_title,
      :include_link,
      :shorten_common_terms
    )
  end
end
