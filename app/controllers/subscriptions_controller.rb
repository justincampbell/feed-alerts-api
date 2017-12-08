class SubscriptionsController < ApplicationController
  def create
    subscription = Subscription.new(create_params)

    # TODO: Assign current user
    subscription.user = User.first

    if subscription.save
      render jsonapi: subscription,
        include: [:feed],
        status: :created
    else
      render jsonapi_errors: subscription.errors,
        status: :forbidden
    end
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