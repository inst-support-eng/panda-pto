require 'rails_helper'

RSpec.describe UsersController, type: :controller do
    describe "Get #current" do
        it "should render current user json" do
            get :current
            expect(response).to have_http_status(:success)
        end
    end

    describe "PUT #update_shift" do

        before(:each) do
           @user = FactoryBot.create(:user) 
        end
        
        it "should update the users shift" do
            put :update_shift, params: {:user_id => @user.id}
            @user.reload
            
            expect(@user.ten_hour_shift).to eq true
        end
    end
end
