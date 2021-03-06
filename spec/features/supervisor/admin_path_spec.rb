require 'rails_helper'

RSpec.feature 'Supervisor Admin Path', type: :feature do
  before(:each) do
    @sup = FactoryBot.create(:user, :supervisor)
    @user = FactoryBot.create(:user_with_one_request)
    @calendar = FactoryBot.create(:calendar)
  end

  after(:each) do
    User.destroy_all
    PtoRequest.destroy_all
    Calendar.destroy_all
  end

  scenario 'should allow admin to access the admin path', js: true do
    sign_in(@sup)
    visit(root_path)
    find('#user-settings').click
    click_link('Admin')

    expect(page).to have_link('Export PTO')

    expect(page).to have_link(@user.name.to_s)
    expect(page).to have_link(@sup.name.to_s)
  end

  scenario 'should not allow normal users to access the admin page', js: true do
    sign_in(@user)
    visit(root_path)
    find('#user-settings').click
    has_no_link?('Admin')

    visit(admin_path)
    expect { visit(admin_path) }.to raise_error(ActionController::RoutingError)
  end

  scenario 'should not show deleted users', js: true do
    sign_in(@sup)
    visit(admin_path)

    expect(page).to have_link(@user.name.to_s)

    @user.is_deleted = true
    @user.save

    visit(admin_path)
    expect(@user.reload.is_deleted).to eq(true)
    expect(page).to have_no_link(@user.name.to_s)
  end
end
