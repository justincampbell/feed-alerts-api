class SerializableEvent < JSONAPI::Serializable::Resource
  type 'events'

  belongs_to :user

  attribute :created_at
  attribute :code
  attribute :detail
  attribute :data
  attribute :error
end
