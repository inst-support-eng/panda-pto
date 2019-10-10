FactoryBot.define do
  factory :pto_request do
    reason { 'disneyland' }
    request_date { 10.days.from_now }
    cost { 10 }
    signed_up_total { 1 }
    user_id { 42 }
    position { 'L1' }
    admin_note { '' }
    excused { false }
    is_deleted { false }
  end
end
