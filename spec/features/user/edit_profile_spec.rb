require 'rails_helper'

RSpec.feature 'Edit Profile', type: :feature do
  before(:each) do
    @user = FactoryBot.create(:user)
  end

  after(:each) do
    User.destroy_all
  end

  scenario 'user successfully navigates to edit profile', js: true do
    sign_in(@user)
    visit(root_path)
    find('#user-settings').click
    find_link('Edit Profile').click
    expect(page).to have_button('Go Back')
  end

  scenario 'user updates password', js: true do
    sign_in(@user)
    visit(root_path)
    find('#user-settings').click
    find_link('Edit Profile').click
    find_button('Reset Password').click

    fill_in('user_current_password', with: @user.password)
    fill_in('user_password', with: '1abcdefg')
    fill_in('user_password_confirmation', with: '1abcdefg')
    find_button('Update').click
    expect(page).to have_css('.alert-success')
  end
end
