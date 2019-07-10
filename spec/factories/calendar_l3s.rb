FactoryBot.define do
  factory :calendar_l3 do
    date { "2019-04-16" }
    base_value { 1.5 }
    signed_up_total { 1 }
    signed_up_agents { [] }
    current_price { 1.5 }
  end
end
