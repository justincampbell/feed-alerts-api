class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  validates :feed,
    uniqueness: { scope: :user, message: "already subscribed to" }

  def preview
    Preview.new(feed.fetch, subscription: self)
  end
end
