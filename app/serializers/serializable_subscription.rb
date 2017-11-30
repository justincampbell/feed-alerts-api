class SerializableSubscription < JSONAPI::Serializable::Resource
  type 'subscriptions'

  belongs_to :user
  belongs_to :feed

  attribute :include_title
  attribute :shorten_common_terms
end
