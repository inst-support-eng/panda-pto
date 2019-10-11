require 'rails_helper'

RSpec.describe PagesHelper, type: :helper do
	describe 'signed in user' do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in(@user, scope: :user)
    end

    it "returns signed_in_links partial's path" do
      expect(helper.pages_path).to (
         eq 'pages/pages_path/calendar'
       )
    end
  end

  describe 'non-signed in user' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it "returns non_signed_in_links partial's path" do
      expect(helper.pages_path).to (
        eq 'pages/pages_path/non_signed_in'
      )
    end
  end
end