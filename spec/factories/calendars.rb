FactoryBot.define do
  factory :calendar do
    date { "2019-02-20" }
    base_value { 1.5 }
    signed_up_total { 1 }
    signed_up_agents { ["some dude"] }
    current_price { 1.5 }
  end
end
