require 'rails_helper'

RSpec.describe ImportDateCsvController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #import" do
    it "returns http success" do
      get :import
      expect(response).to have_http_status(:success)
    end
  end

end
