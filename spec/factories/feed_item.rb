FactoryBot.define do
  factory :feed_item, aliases: [:item] do
    feed
    guid { SecureRandom.uuid }
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
  end
end
