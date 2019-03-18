require 'rails_helper'

RSpec.describe CalendarsController, type: :controller do
    describe "GET #fetch_dates" do
        it "should render all calendar dates" do
            get :fetch_dates
            expect(response).to have_http_status(:success)
        end
    end
end