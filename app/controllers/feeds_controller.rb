class FeedsController < ApplicationController
  def index
    query = params.dig(:filter, :query)

    unless query
      render jsonapi: []
      return
    end

    feeds = Feed.where("name like '%#{query}%'")
    render jsonapi: feeds
  end

  def create
    unless current_user
      render_jsonapi_error 403, "Forbidden"
      return
    end

    feed = Feed.new(create_params)
    feed.created_by = current_user

    begin
      feed.name = feed.fetch.title
    rescue Feedjira::NoParserAvailable
      render_jsonapi_error 422, "Not a valid XML feed"
      return
    rescue Errno::ECONNREFUSED
      render_jsonapi_error 422, "Not a valid URL"
      return
    end

    if feed.save
      render jsonapi: feed,
        include: [:feed],
        status: :created

      FeedCheckJob.perform_later feed.id
    else
      render jsonapi_errors: feed.errors,
        status: :forbidden
    end
  end

  def create_params
    jsonapi_params.permit(
      :kind,
      :url
    )
  end
end
