FactoryBot.define do
  factory :user do
    sms_number { Faker::PhoneNumber.cell_phone }
  end
end
