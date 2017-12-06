class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :sms_number,
    phone: { possible: true }

  def sms_number=(value)
    phone = Phonelib.parse(value)
    self[:sms_number] = phone.sanitized
  end
end
