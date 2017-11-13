class SerializableFeed < JSONAPI::Serializable::Resource
  type 'feeds'

  attribute :name
  attribute :url
end
