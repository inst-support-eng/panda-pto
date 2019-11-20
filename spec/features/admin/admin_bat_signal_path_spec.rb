require 'rails_helper'

RSpec.feature 'Admin Bat Signal Path', type: :feature do
  before(:each) do
    @admin = FactoryBot.create(:user, :admin)
    @user = FactoryBot.create(:user)
    @user_no_phone = FactoryBot.create(:user, :no_phone)
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

  scenario 'users without phone numbers should appear with a different background', js: true do
    sign_in(@admin)
    visit(admin_bat_signal_path)

    expect(page).to have_css('.no-ph-num')
  end

  scenario 'should allow admins to messages through bat signal page', js: true do
    sign_in(@admin)
    visit(admin_bat_signal_path)

    fill_in('message_message', with: 'test')
    first(:css, '.all-agents-row').set(true)

    accept_alert do
      click_on('create message')
    end

    visit(admin_bat_signal_path)
    expect(Message.count).to eq(2)
  end
end
