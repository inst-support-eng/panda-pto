require 'rails_helper'

RSpec.describe NavigationHelper, type: :helper do
  describe 'signed in user' do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in(@user, scope: :user)
    end

    it "returns signed_in_links partial's path" do
      expect(helper.collapsible_links_partial_path).to eq('layouts/navigation/collapsible_elements/signed_in_links')
    end
  end

  describe 'non-signed in user' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it "returns non_signed_in_links partial's path" do
      expect(helper.collapsible_links_partial_path).to eq('layouts/navigation/collapsible_elements/non_signed_in_links')
    end
  end
end
