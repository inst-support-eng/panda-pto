require 'rails_helper'

RSpec.describe UsersController, type: :controller do
    describe "GET #show" do 
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end

        it "should display user" do 
        end
    end 

    desribe "DELETE #destroy" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should delete user and all requests" do 
        end
    end

    describe "Get #current" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should render current user json" do
            get :current
            expect(response).to have_http_status(:success)
        end
    end

    describe "PUT #update_shift" do
        before(:each) do
           @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should update true ten_hour_shift to false" do
            put :update_shift, params: {:user_id => @user.id}
            @user.reload
            
            expect(@user.ten_hour_shift).to eq true
        end

        it "should update false ten_hour_shift to true" do
        end
    end

    describe "POST #update_admin" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end

        it "should udpate true update_admin to false" do 
        end

        it "should update false update_admin to true" do 
        end
    end

    describe "POST #update_pip" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should update true update_pip to false" do 
        end

        it "should update false update_pip to true" do 
        end
    end
end
