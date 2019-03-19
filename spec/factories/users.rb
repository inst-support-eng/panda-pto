FactoryBot.define do 
    factory :user do
      id { 1 }
      name { "test" }
      email { "test@test.com" }
      password { '123456' }
      password_confirmation { '123456' }
      bank_value { 150 }
      humanity_user_id { 1 } 
      ten_hour_shift { false }
    end
  end