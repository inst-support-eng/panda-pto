require 'rails_helper'

RSpec.feature 'Admin Path', type: :feature do
  before(:each) do
    @admin = FactoryBot.create(:admin)
    @user = FactoryBot.create(:user_with_one_request)
    @calendar = FactoryBot.create(:calendar)
  end

  after(:each) do
    User.destroy_all
    PtoRequest.destroy_all
    Calendar.destroy_all
  end

  scenario 'should allow admin to access the admin path', js: true do
    sign_in(@admin)
    visit(root_path)
    find('#user-settings').click
    click_link('Admin')

    find_by_id('values-csv')
    find_by_id('users-csv')
    find_by_id('pto-csv')
    find_by_id('adjust-calendar-cost-btn')

    expect(page).to have_link(@user.name.to_s)
    expect(page).to have_link(@admin.name.to_s)
  end

  scenario 'should not allow normal users to access the admin page', js: true do
    sign_in(@admin)
    visit(root_path)
    find('#user-settings').click
    has_no_link?('Admin')

    visit(admin_path)
    has_no_css?('values-csv')
  end
end
