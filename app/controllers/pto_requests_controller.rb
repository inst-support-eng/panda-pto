class PtoRequestsController < ApplicationController 
    def show
        @pto_request = pto_request.find(params[:id])
    end

    def new  
        @pto_request = PtoRequest.new
    end

    def create
        @pto_request = PtoRequest.new(post_params)
        @pto_request.signed_up_total == nil ? @pto_request.signed_up_total = 1 : @pto_request.signed_up_total += 1;

        if @pto_request.save
            redirect_to root_path
        else
            redirect_to root_path
        end
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date).merge(user_id: current_user.id )
    end
end