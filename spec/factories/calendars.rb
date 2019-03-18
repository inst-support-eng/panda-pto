FactoryBot.define do
  factory :calendar do
    date { 10.days.from_now }
    base_value { 1.5 }
    signed_up_total { 1 }
    signed_up_agents {[]}
    current_price { 1.5 }
  end
end
