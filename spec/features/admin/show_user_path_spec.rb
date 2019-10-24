require 'rails_helper'

RSpec.feature 'Admin show_user path', type: :feature do
  before(:each) do
    @admin = FactoryBot.create(:user, :admin)
    @user = FactoryBot.create(:user_with_one_request)
    @deleted_user = FactoryBot.create(:user, :deleted_user)
    @calendar = FactoryBot.create(:calendar, :calendar_tomorrow)
    @calendar_today = FactoryBot.create(:calendar, :calendar_today)
    @request_date = FactoryBot.create(:calendar)
    sign_in(@admin)
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
    expect(page).to have_button('Toggle Admin')
    expect(page).to have_button('Toggle Pip')
    expect(page).to have_button('Delete User')
  end

  scenario 'should be able to add pto request', js: true do
    visit(show_user_path(@user))

    expect(@user.pto_requests.count).to eq(1)

    request = @calendar.date.strftime('%m/%d/%Y')

    click_button('Add Request')

    page.has_content?(`Current Price for today: #{@calendar_today.current_price}`)
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

  scenario 'should be able to toggle 8/10 hour shift', js: true do
    visit(show_user_path(@user))
    expect(@user.ten_hour_shift).to eq(false)

    click_button('8/10 hour shift')

    visit(show_user_path(@user))
    expect(@user.reload.ten_hour_shift).to eq(true)
  end

  scenario 'should be able to toggle admin of user', js: true do
    visit(show_user_path(@user))
    expect(@user.admin).to eq(false)

    click_button('Toggle Admin')

    visit(show_user_path(@user))
    expect(@user.reload.admin).to eq(true)
  end

  scenario 'should be able to toggle pip of user', js: true do
    visit(show_user_path(@user))
    expect(@user.on_pip).to eq(false)

    click_button('Toggle Pip')

    visit(show_user_path(@user))
    expect(@user.reload.on_pip).to eq(true)
  end

  scenario 'should be able to delete user', js: true do
    visit(show_user_path(@user))

    accept_alert do
      click_button('Delete User')
    end

    visit(show_user_path(@user))

    expect(@user.reload.is_deleted).to eq(true)
    expect(@user.reload.pto_requests.count).to eq(1)
    expect(@user.reload.pto_requests.where(is_deleted: true).count).to eq(1)
    expect(page).to have_button('Restore User')
  end

  scenario 'should be able to restore deleted user', js: true do
    visit(show_user_path(@deleted_user))

    accept_alert do
      click_button('Restore User')
    end

    visit(show_user_path(@deleted_user))
    expect(@deleted_user.reload.is_deleted).to eq(false)
    expect(page).to have_button('Delete User')

    visit(admin_path)
    expect(page).to have_link(@deleted_user.name.to_s)
  end

  scenario 'should be able to delete a request', js: true do
    visit(show_user_path(@user))

    accept_alert do
      click_button('Delete')
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
