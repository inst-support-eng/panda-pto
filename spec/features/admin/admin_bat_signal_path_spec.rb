require 'rails_helper'

RSpec.feature 'Admin Bat Signal Path', type: :feature do
  before(:each) do
    @admin = FactoryBot.create(:user, :admin)
    @user = FactoryBot.create(:user_with_one_request)
    @message = FactoryBot.create(:message)
  end

  after(:each) do
    User.destroy_all
    Message.destroy_all
  end

  scenario 'should allow admin to access the bat signal path', js: true do
    sign_in(@admin)
    visit(admin_path)
    click_link('Batsignal')

    expect(page).to have_link('Export Messages')
  end

  scenario 'should not allow normal users to access the bat signal page', js: true do
    sign_in(@user)
    visit(admin_bat_signal_path)

    expect { visit(admin_path) }.to raise_error(ActionController::RoutingError)
  end

  scenario 'should allow admins to messages through bat signal page', js: true do
  end
end
