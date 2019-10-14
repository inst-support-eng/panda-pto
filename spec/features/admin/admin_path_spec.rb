require 'rails_helper'
require 'spec_helper'

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

    expect(page).to have_button('Upload Values')
    expect(page).to have_button('Upload Users')
    expect(page).to have_button('Import Requests')
    expect(page).to have_button('Adjust Date Costs')

    expect(page).to have_link(@user.name.to_s)
    expect(page).to have_link(@admin.name.to_s)
  end
end
