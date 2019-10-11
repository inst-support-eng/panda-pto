require 'rails_helper'

RSpec.feature 'Logout', type: :feature do
  before(:each) do
    @user = FactoryBot.create(:user)
  end

  scenario 'user successfully logs out', js: true do
    sign_in(@user)
    visit(root_path)
    find('nav #user-settings').click
    find_link('Log out').click
    expect(page).to have_button('Log in')
  end
end
