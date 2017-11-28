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

  def preview
    feed = Feed.find(params[:feed_id])
    feed_response = feed.fetch
    preview = Preview.new(feed_response)
    render jsonapi: preview
  end
end
