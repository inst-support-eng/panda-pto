require 'rails_helper'

RSpec.describe UsersController, type: :controller do
    describe "DELETE #destroy" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should delete user and all requests" do 
            PtoRequest.create({:user_id => @user.id, :reason => 'disneyland', 
                :request_date => 10.days.from_now, :cost => 10})

            expect(PtoRequest.count).to eq(1)

            delete :destroy, params: {:user_id => @user.id}

            expect(PtoRequest.count).to eq(0)
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
        
        it "should update ten_hour_shift = false to true" do
            put :update_shift, params: {:user_id => @user.id}
            @user.reload
            
            expect(@user.ten_hour_shift).to be(true)
        end

        it "should update ten_hour_shift = true to false" do
            @user.ten_hour_shift = true
            @user.save
            @user.reload

            expect(@user.ten_hour_shift).to be(true)

            put :update_shift, params: {:user_id => @user.id}
            @user.reload

            expect(@user.ten_hour_shift).to be(false)
        end
    end

    describe "POST #update_admin" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end

        it "should admin = false to true" do
            post :update_admin, params: {:user_id => @user.id} 
            @user.reload

            expect(@user.admin).to be(true)
        end

        it "should admin = true to false" do 
            @user.admin = true
            @user.save            
            @user.reload

            expect(@user.admin).to be(true)
            
            post :update_admin, params: {:user_id => @user.id} 
            @user.reload

            expect(@user.admin).to be(false)
        end
    end

    describe "POST #update_pip" do
        before(:each) do
            @user = FactoryBot.create(:user) 
        end
        after(:each) do 
            User.delete_all
        end
        
        it "should update on_pip = false to true" do 
            post :update_pip, params: {:user_id => @user.id}
            @user.reload

            expect(@user.on_pip).to be(true)
        end

        it "should update false on_pip = true to false" do 
            @user.on_pip = true
            @user.save
            @user.reload

            expect(@user.on_pip).to be(true)

            post :update_pip, params: {:user_id => @user.id}
            @user.reload

            expect(@user.on_pip).to be(false)
        end
    end
end
