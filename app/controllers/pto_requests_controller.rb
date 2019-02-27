class PtoRequestsController < ApplicationController 

    def show
        @pto_request = pto_request.find(params[:id])
    end

    def new  
        @pto_request = PtoRequest.new
    end

    # !TECHBEDT prevent past dates and duplicates from being entered in calendar by a user
    def create
        @pto_request = PtoRequest.new(post_params)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)
        @user = User.find_by(:id => @pto_request.user_id)

        if @calendar != nil
            @pto_request.signed_up_total = @calendar.signed_up_total  
            update_calendar
        else 
            @pto_request.signed_up_total == nil ? @pto_request.signed_up_total = 1 : @pto_request.signed_up_total += 1;
        end 

        if @user != nil
            puts @calendar.current_price
            puts @user.name
            puts @pto_request.cost

            @user.bank_value -= @pto_request.cost
            @user.save
        end

        if @pto_request.save
            redirect_to root_path
        else
            flash[:notice] = "something went wrong"
            redirect_to root_path
        end
    end

    # !TECHBEDT prevent users from deleting past dates
    def destroy
        @pto_request = PtoRequest.find(params[:id])
        @user = User.find_by(:id => @pto_request.user_id)

        @user.bank_value += @pto_request.cost
        @user.save

        @pto_request.destroy

        redirect_to '/', :flash => {:notice => "Your request has been deleted"}
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date, :cost).merge(user_id: current_user.id)
    end

    def update_calendar
        @calendar.signed_up_total == nil ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(current_user.name)
        
        @calendar.save
    end
end