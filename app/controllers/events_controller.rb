class EventsController < ApplicationController
  def index
    return head 404 unless current_user&.admin?

    render jsonapi: Event.all,
      include: %i[user]
  end
end
