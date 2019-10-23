require 'rails_helper'

RSpec.feature 'Add Requests', type: :feature do
  before(:each) do
    @user = FactoryBot.create(:user)
    @calendar = FactoryBot.create(:calendar)
  end

  after(:each) do
    User.destroy_all
  end

  scenario 'user is able to make a request from the calendar', js: true do
    sign_in(@user)
		visit(root_path)

		if @calendar.date.month != Date.today.month
			find_by_id('next').click
		end

		find_by_id(@calendar.date.to_s).click
		
    fill_in('pto_request_reason', with: 'selenium test')
    click_on('create request')

    expect('.day-off')
    expect('a Delete')

    expect(@user.reload.pto_requests.count).to eq(1)
  end
end
