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
        @user = User.find_by(:id => @pto_request.user_id)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)

        if @calendar.signed_up_agents.include?(@user.name)
            redirect_to root_path, notice: "You already have a request for this date"
            return 
        end 

        if @user.bank_value < @pto_request.cost
            redirect_to root_path, notice: "You do not have enough to make this request"
            return 
        end
        
        if @pto_request.save
            redirect_to root_path
            update_request_info

            case @pto_request.request_date
            when Date.today
                puts 'today'
                # RequestsMailer.with(user: @user, pto_request: @pto_request).day_of_request_email.deliver_now  
            when Date.today ... 2.days.from_now
                puts '48 hours'
                # RequestsMailer.with(user: @user, pto_request: @pto_request).two_day_out_request.deliver_now
            else 
                RequestsMailer.with(user: @user, pto_request: @pto_request).requests_email.deliver_now
            end
        else
            redirect_to root_path, notice: "something went wrong"
        end
    end

    def destroy
        @pto_request = PtoRequest.find(params[:id])
        @user = User.find_by(:id => @pto_request.user_id)
        @calendar = Calendar.find_by(:date => @pto_request.request_date)

        if @pto_request.destroy
            remove_request_info
            RequestsMailer.with(user: @user, pto_request: @pto_request).delete_request_email.deliver_now
            redirect_to root_path, notice: "Your request was deleted"
        else
            redirect_to root_path, notice: "Somthing went wrong"
        end

    end

    def excuse_request
        @pto_request = PtoRequest.find(params[:id])

        if @pto_request == true
            redirect_to show_user_path(@user), notice: "the request is already excused"
        end
        @user = User.find_by(:id => @pto_request.user_id)

        @pto_request.excused = true
        @pto_request.admin_note = "excused by #{current_user.name}"

        @user.bank_value += @pto_request.cost
        @pto_request.save
        @user.save

        redirect_to show_user_path(@user)
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date, :cost).merge(user_id: current_user.id)
    end

    # update calednar && user with new request info
    def update_request_info
        humanity_request_id = HumanityAPI.create_request(@pto_request, @user)
        HumanityAPI.approve_request(humanity_request_id)
        @pto_request.humanity_request_id = humanity_request_id 
        @pto_request.excused = false
        @pto_request.save

        @calendar.signed_up_total == nil ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(current_user.name)
        
        @calendar.save

        @user.bank_value -= @pto_request.cost
        @user.save

        helpers.update_price(@calendar.date)
    end

    # remove needed info to update the calendar and user appropriately 
    def remove_request_info
        HumanityAPI.delete_request(@pto_request.humanity_request_id)

        @calendar.signed_up_agents.delete(@user.name)
        @calendar.save

        @user.bank_value += @pto_request.cost
        @user.save
    end
end