require 'rails_helper'

RSpec.describe "Faqs", type: :request do
  describe "GET /faqs" do
    it "works! (now write some real specs)" do
      get faqs_path
      expect(response).to have_http_status(200)
    end
  end
end
