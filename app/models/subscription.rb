class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  validates :feed,
    uniqueness: { scope: :user, message: "already subscribed to" }
end
