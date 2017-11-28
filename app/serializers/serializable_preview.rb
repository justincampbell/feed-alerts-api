class SerializablePreview < JSONAPI::Serializable::Resource
  type 'previews'

  attribute :text
end
