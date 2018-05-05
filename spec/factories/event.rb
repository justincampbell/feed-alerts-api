FactoryBot.define do
  factory :event do
    association :resource, factory: :user
    code { Event::VALID_CODES.sample }
  end
end
