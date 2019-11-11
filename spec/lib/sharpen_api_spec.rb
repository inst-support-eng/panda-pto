require 'rails_helper'
require 'spec_helper'

describe 'Sharpen API' do
  it 'should send a sms and give a Complete response' do
    response = SharpenAPI.send_sms('rspec', ENV['TEST_PH_NUM'])
    expect(response).to eq('A total of 1 messages have been sent.')
  end

  it 'should send multiple sms and give a Complete response' do
    response = SharpenAPI.send_sms(
      'rspec', [ENV['TEST_PH_NUM'], ENV['TEST_PH_NUM']]
    )
    expect(response).to eq('A total of 2 messages have been sent.')
  end
end
