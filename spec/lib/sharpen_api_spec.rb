require 'rails_helper'
require 'spec_helper'

describe 'Sharpen API' do
  it 'should send a sms and give a Complete response' do
    response = SharpenAPI.send_sms('rspec', ['123-123-1234'])
    expect(response).to eq(1)
  end

  it 'should send multiple sms and give a Complete response' do
    response = SharpenAPI.send_sms(
      'rspec', %w[123-123-1234 123-123-1234]
    )
    expect(response).to eq(1)
  end
end
