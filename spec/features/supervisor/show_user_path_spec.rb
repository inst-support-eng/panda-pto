require 'rails_helper'

RSpec.feature 'Admin show_user path', type: :feature do
  before(:each) do
    @sup = FactoryBot.create(:user, :supervisor)
    @user = FactoryBot.create(:user_with_one_request)
    @calendar = FactoryBot.create(:calendar, :calendar_tomorrow)
    @calendar_today = FactoryBot.create(:calendar, :calendar_today)
    @request_date = FactoryBot.create(:calendar)
    sign_in(@sup)
  end

  after(:each) do
    User.destroy_all
    PtoRequest.destroy_all
    Calendar.destroy_all
  end

  scenario 'should be able to get to users page', js: true do
		visit(admin_path)
		page.has_content?(@user.name.to_s)
		visit(show_user_path(@user))

    expect(page).to have_button('Add Request')
    expect(page).to have_link('User PTO Requests')
    expect(page).to have_button('Password Reset')
    expect(page).to have_button('8/10 hour shift')
    expect(page).to have_button('Add No Show')
    expect(page).to have_button('Add Make Up / Sick Day')
  end

  scenario 'should be able to add pto request', js: true do
    visit(show_user_path(@user))

    expect(@user.pto_requests.count).to eq(1)

    request = @calendar.date.strftime('%m/%d/%Y')

    click_button('Add Request')

    fill_in('pto_request_reason', with: 'test')
    fill_in('pto_request_request_date', with: request)
    fill_in('pto_request_cost', with: '10')

    click_button('create request')

    visit(show_user_path(@user))

    expect(@user.reload.pto_requests.count).to eq(2)
    expect(@user.reload.pto_requests.last.reason).to include('requested by')
  end

  scenario 'should be able to add sick day request', js: true do
    visit(show_user_path(@user))

    expect(@user.pto_requests.count).to eq(1)
    expect(@user.make_up_days).to eq(0)

    request = @calendar.date.strftime('%m/%d/%Y')

    click_button('Add Make Up / Sick Day')
    fill_in('pto_request_request_date', with: request)
    click_button('create request')

    visit(show_user_path(@user))

    expect(@user.reload.pto_requests.count).to eq(2)
    expect(@user.reload.make_up_days).to eq(1)
  end

  scenario 'should be able to add no call / show request', js: true do
    visit(show_user_path(@user))

    expect(@user.pto_requests.count).to eq(1)
    expect(@user.no_call_show).to eq(0)

    request = @calendar.date.strftime('%m/%d/%Y')

    click_button('Add No Show')
    fill_in('pto_request_request_date', with: request)
    click_button('create request')

    visit(show_user_path(@user))

    expect(@user.reload.pto_requests.count).to eq(2)
    expect(@user.reload.no_call_show).to eq(1)
  end

  scenario 'should be able to delete a request', js: true do
    visit(show_user_path(@user))

    accept_alert do
      click_link('Delete')
    end

    visit(show_user_path(@user))
    expect(@user.reload.pto_requests.where(is_deleted: true).count).to eq(1)
  end

  scenario 'should be able to excuse request', js: true do
    visit(show_user_path(@user))

    click_button('Excuse Request')

    visit(show_user_path(@user))
    expect(@user.reload.pto_requests.where(excused: true).count).to eq(1)
  end
end
