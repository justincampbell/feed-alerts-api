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
    render jsonapi: subscription.preview
  end

  private

  def create_params
    jsonapi_params.permit(
      :feed_id,
      :include_title,
      :shorten_common_terms
    )
  end

  def jsonapi_params
    ActionController::Parameters.new(
      ActiveModelSerializers::Deserialization.jsonapi_parse!(
        params[:_jsonapi]
      )
    )
  end
end
