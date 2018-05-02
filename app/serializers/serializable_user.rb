class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'

  has_many :events

  attribute :sms_number
end
