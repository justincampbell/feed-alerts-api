class SerializableSession < JSONAPI::Serializable::Resource
  type 'sessions'

  attribute :token
  attribute :expires_at
end
