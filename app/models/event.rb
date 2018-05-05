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

  belongs_to :resource,
    polymorphic: true

  validates :code,
    inclusion: { in: VALID_CODES }

  def self.record(code, sms_number: nil, resource: nil, detail: nil, data: {})
    if sms_number
      resource = User.find_or_create_by(sms_number: sms_number)
    end

    raise "Must pass resource" unless resource

    Event.create!(
      resource: resource,
      code: code,
      detail: detail,
      data: data
    )
  end
end
