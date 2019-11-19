FactoryBot.define do
  factory :message do
    recipients { ['Rspec User'] }
    recipient_numbers { [ENV['TEST_PH_NUM']] }
    author { 42 }
    message { 'Rspec test' }
  end
end
