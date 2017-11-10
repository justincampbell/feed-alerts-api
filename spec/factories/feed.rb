FactoryBot.define do
  factory :feed do
    name { Faker::Name.name }
    url { Faker::Internet.url }
  end
end
