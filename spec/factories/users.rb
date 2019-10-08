# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:id) { |n| n }
    name { |n| "test#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { '123456' }
    password_confirmation { '123456' }
    bank_value { 150 }
    sequence(:humanity_user_id) { |n| n }
    ten_hour_shift { false }
    position { 'L1' }
    admin { false }
    on_pip { false }
    no_call_show { 0 }
    make_up_days { 0 }
    start_date { '2018-01-01' }
  end
end
