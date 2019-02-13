FactoryBot.define do 
    factory :user do
      name { "test" }
      email { "test@test.com" }
      password { '123456' }
      password_confirmation { '123456' }
      bank_value { 150 }
    end
  end