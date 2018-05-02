class Event < ApplicationRecord
  VALID_CODES = %w[
    error
    session-created
    session-destroyed
    sms-received
    sms-sent
    subscription-created
    verification-code-sent
  ]

  belongs_to :user

  validates :code,
    inclusion: { in: VALID_CODES }

  def self.record(code, sms_number: nil, user: nil, detail: nil, data: {})
    unless user
      raise "Must pass sms_number or user" unless sms_number

      user = User.find_or_create_by(sms_number: sms_number)
    end

    Event.create!(
      user: user,
      code: code,
      detail: detail,
      data: data
    )
  end
end
