FactoryBot.define do
  factory :user do
    sms_number { Faker::PhoneNumber.cell_phone }

    trait :admin do
      admin true
    end
  end
end
