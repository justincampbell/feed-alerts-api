class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'

  attribute :sms_number
end
