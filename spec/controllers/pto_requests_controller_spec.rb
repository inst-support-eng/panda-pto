require 'rails_helper' 

RSpec.describe PtoRequestsController, type: :controller do
    before(:each) do 
        @user = FactoryBot.create(:user)
        @calendar = FactoryBot.create(:calendar)
        sign_in(@user, scope: :user)
    end
    describe "POST #create" do 
        it "should allow user with enough credits to request a day" do
            post :create, params: {:user_id => @user.id, :reason => "butts", :request_date => 10.days.from_now, :cost => 10}
            @user.reload 
            @calendar.reload
            expect(@user.bank_value).to eq(140)
        end 

        it "should allow a user to request a day that they have not already requests off" do
            post :create, params: {:user_id => @user.id, :reason => "butts", :request_date => 10.days.from_now, :cost => 10}
            @user.reload 
            @calendar.reload
            expect(@calendar.signed_up_agents).to include(@user.name)
        end 

        it "should not allow a user to make a request if they do not have enough credits" do
            post :create, params: {:user_id => @user.id, :reason => "also butts", :request_date => 10.days.from_now, :cost => 160}
            @user.reload
            @calendar.reload
            expect(@calendar.signed_up_agents).to_not include(@user.name)
            expect(@user.bank_value).to eq 150
        end

        it "should not allow a user to make a request if they already have the day off" do
            @calendar.signed_up_agents.push(@user.name)
            @calendar.save
            @calendar.reload

            post :create, params: {:user_id => @user.id, :reason => "also butts", :request_date => 10.days.from_now, :cost => 10}
            @user.reload
            @calendar.reload

            expect(@calendar.signed_up_agents.count).to be 1
            expect(@user.bank_value).to eq 150
        end
    end

    describe "DELETE #destroy" do
        it "should give credits back to the user for the cost of the day" do
        end

        it "should remove them from the calendar date, allowing them re-request the day" do
        end
    end
end