require 'rails_helper'

RSpec.feature 'Login', type: :feature do
  before(:each) do
    @user = FactoryBot.create(:user)
  end

  scenario 'user navigates to the login page and succesfully logs in', js: true do
    visit(root_path)
    fill_in('user_email', with: @user.email)
    fill_in('user_password', with: @user.password)
    find('.login-button').click
    expect(page).to have_selector('#user-settings')
  end
end
