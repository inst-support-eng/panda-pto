require 'rails_helper' 

RSpec.describe PtoRequestsController, type: :controller do
    before(:each) do 
        @user = FactoryBot.create(:user)
        @calendar = FactoryBot.create(:calendar)
        sign_in :user, @user
    end
    describe "POST #create" do 
        it "should allow user with enough credits to request a day" do
            post :create, params: {:user_id => @user.id, :reason => "butts", :request_date => 10.days.from_now, :cost => 10}
            @user.reload 
            @calendar.reload
            expect(@user.bank_value).to eq(140)
            expect(@calendar.signed_up_agents).to include(@user.name)
        end 

        it "should allow a user to request a day that they have not already requests off" do
        end 

        it "should not allow a user to make a request if they do not have enough credits" do
        end

        it "should not allow a user to make a request if they already have the day off" do
        end
    end

    describe "DELETE #destroy" do
        it "should give credits back to the user for the cost of the day" do
        end

        it "should remove them from the calendar date, allowing them re-request the day" do
        end
    end
end