require 'rails_helper'

RSpec.feature 'Delete Requests', type: :feature do
  before(:each) do
    @user = FactoryBot.create(:user_with_one_request)
    @calendar = FactoryBot.create(:calendar)

    sign_in(@user)
  end

  after(:each) do
    User.destroy_all
    PtoRequest.destroy_all
    Calendar.destroy_all
  end

  scenario 'should be able to delete request from user profile', js: true do
    visit(edit_user_registration_path)

    accept_alert do
      click_link('Delete')
    end

    visit(edit_user_registration_path)

    expect(@user.reload.pto_requests.count).to eq(1)
    expect(@user.pto_requests.where(is_deleted: true).count).to eq(1)
  end

  scenario 'should be able to delete requests from calendar page', js: true do
    visit(root_path)

    accept_alert do
      click_link('Delete')
    end
    visit(root_path)

    expect(@user.reload.pto_requests.count).to eq(1)
    expect(@user.reload.pto_requests.where(is_deleted: true).count).to eq(1)
  end
end
