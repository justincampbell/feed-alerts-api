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
end
