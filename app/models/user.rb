class User < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :sms_number,
    phone: { possible: true }

  def sms_number=(value)
    self[:sms_number] = SMS.normalize(value)
  end

  def deliver_message(body)
    SMS.new.send sms_number, body
  end
end
