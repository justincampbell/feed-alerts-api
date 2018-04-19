class Event < ApplicationRecord
  VALID_CODES = %w[
    sms-received
    sms-sent
  ]

  belongs_to :user

  validates :code,
    inclusion: { in: VALID_CODES }
end
