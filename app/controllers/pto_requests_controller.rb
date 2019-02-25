class PtoRequestsController < ApplicationController 

    def show
        @pto_request = pto_request.find(params[:id])
    end

    def new  
        @pto_request = PtoRequest.new
    end

    def create
        @pto_request = PtoRequest.new(post_params)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)
        if @calendar != nil
            @pto_request.signed_up_total = @calendar.signed_up_total 
            @pto_request.cost = @calendar.current_price  
            update_calendar
        else 
            @pto_request.signed_up_total == nil ? @pto_request.signed_up_total = 1 : @pto_request.signed_up_total += 1;
        end 

        if @pto_request.save
            redirect_to root_path
        else
            flash[:notice] = "something went wrong"
            redirect_to root_path
        end
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date).merge(user_id: current_user.id)
    end

    def update_calendar
        @calendar.signed_up_total == nil ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(current_user.name)
        
        @calendar.save
    end
end