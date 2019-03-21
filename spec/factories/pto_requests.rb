FactoryBot.define do
  factory :pto_request do
    reason { "disneyland"}
    request_date { "2019-04-20" }
    cost { 69 }
    signed_up_total { 69 }
    user_id { @user.id }
    sequence(:humanity_request_id) { 1994 }
  end
end
