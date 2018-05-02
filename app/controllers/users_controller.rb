class UsersController < ApplicationController
  def index
    return head 404 unless current_user&.admin?

    render jsonapi: User.all
  end

  def show
    return head 404 unless current_user&.admin?

    render jsonapi: User.find(params[:id]),
      include: %i[events]
  end
end
