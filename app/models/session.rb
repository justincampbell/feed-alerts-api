class Session < ApplicationRecord
  EXPIRATION = 2.weeks

  belongs_to :user

  attribute :token, :string, default: -> { SecureRandom.urlsafe_base64(32) }

  def expires_at
    updated_at + EXPIRATION
  end
end
