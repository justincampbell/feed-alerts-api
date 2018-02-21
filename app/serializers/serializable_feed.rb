class SerializableFeed < JSONAPI::Serializable::Resource
  type 'feeds'

  attribute :kind
  attribute :name
  attribute :url
end
