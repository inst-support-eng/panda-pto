class PtoRequestsController < ApplicationController 

    def show
        @pto_request = pto_request.find(params[:id])
    end

    def new  
        @pto_request = PtoRequest.new
    end

    # !TECHBEDT flash is not working
    def create
        @pto_request = PtoRequest.new(post_params)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)
        @user = User.find_by(:id => @pto_request.user_id)

        if @calendar.signed_up_agents.include?(@user.name)
            redirect_to '/'
            flash[:notice] = "You already have a request for this date"
            return 
        end 
        if @pto_request.save
            redirect_to root_path
            update_request_info
            RequestsMailer.with(user: @user, pto_request: @pto_request).requests_email.deliver_now
        else
            flash[:notice] = "something went wrong"
            redirect_to root_path
        end
    end

    def destroy
        @pto_request = PtoRequest.find(params[:id])
        @user = User.find_by(:id => @pto_request.user_id)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)

        remove_request_info
        @pto_request.destroy

        redirect_to '/', :flash => {:notice => "Your request has been deleted"}
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date, :cost).merge(user_id: current_user.id)
    end

    # update calednar && user with new request info
    def update_request_info
        @calendar.signed_up_total == nil ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(current_user.name)
        
        @calendar.save

        @user.bank_value -= @pto_request.cost
        @user.save
    end

    # remove needed info to update the calendar and user appropriately 
    def remove_request_info
        @calendar.signed_up_agents.delete(@user.name)
        @calendar.save

        @user.bank_value += @pto_request.cost
        @user.save
    end
end