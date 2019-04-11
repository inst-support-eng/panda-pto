require 'rails_helper'

RSpec.describe SupController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #coverage" do
    it "returns http success" do
      get :coverage
      expect(response).to have_http_status(:success)
    end
  end

end
