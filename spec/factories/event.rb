FactoryBot.define do
  factory :event do
    user
    code { Event::VALID_CODES.sample }
  end
end
