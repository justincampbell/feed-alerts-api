class Event < ApplicationRecord
  VALID_CODES = %w[
    error
    session-created
    session-destroyed
    sms-received
    sms-sent
    subscription-created
    verification-code-sent

    fetch
  ]

  belongs_to :resource,
    polymorphic: true

  validates :code,
    inclusion: { in: VALID_CODES }

  def self.record(code, resource: nil, sms_number: nil, detail: nil, data: {}, error: false)
    if sms_number
      resource = User.find_or_create_by(sms_number: sms_number)
    end

    raise "Must pass resource" unless resource

    Event.create!(
      resource: resource,
      code: code,
      detail: detail,
      data: data,
      error: error
    )
  end
end
