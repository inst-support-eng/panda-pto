FactoryBot.define do
  factory :message do
    recipients { ['Rspec User'] }
    recipient_numbers { ['123-123-1234'] }
    author { 42 }
    message { 'Rspec test' }
  end
end
