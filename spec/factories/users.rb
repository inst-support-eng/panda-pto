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
    is_deleted { false }
    start_time { '15:00Z' }
    end_time { '23:00Z' }
    work_days { [1, 2, 3, 4, 5] }

    trait :admin do
      admin { true }
    end

    trait :supervisor do
      position { 'Sup' }
    end

		trait :deleted_user do
			is_deleted { true }
		end

    factory :user_with_requests do
      transient do
        request_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:pto_request, evaluator.request_count, user: user)
      end
    end

    factory :user_with_one_request do
      transient do
        request_count { 1 }
      end

      after(:create) do |user, evaluator|
        create_list(:pto_request, evaluator.request_count, user: user)
      end
    end
  end
end
