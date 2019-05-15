class PtoRequestsController < ApplicationController
    before_action :login_required
    def export
        @export_pto = PtoRequest.all
        respond_to do |format|
            format.csv { send_data @export_pto.to_csv }
        end
    end

    def import_request
        if params[:file]
            PtoRequest.import(params[:file])
            # update the current price of requests
            dates = []
            CSV.foreach(params[:file].path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
                dates.push(row[:date])
            end
            dates.uniq.each { |x| helpers.update_price(x) }
            redirect_to root_url, notice: "PTO requests imported!"
        else
            redirect_to root_url, notice: "Weep Womp. Please upload a valid CSV file"
        end
    end

    def export_user_request
        @user = User.find(params[:id])
        @user_requests = @user.pto_requests

        respond_to do |format|
            format.csv { send_data @user_requests.to_csv}
        end
    end

    def show
        @pto_request = pto_request.find(params[:id])
    end

    def new
        @pto_request = PtoRequest.new
    end

    def create
        @pto_request = PtoRequest.new(post_params)
        @user = User.find_by(:id => @pto_request.user_id)

        if @pto_request.reason == 'no call / no show'
            return add_no_call_show
        end 

        if @pto_request.reason == 'make up / sick day'
            return add_make_up_day
        end 
        
        if @user.on_pip == true && @user.id == current_user.id
            return redirect_to root_path, notice: "You're PTO is currently restricted, please talk to your supervisor"
        end    

        case @user.position
        when 'L1'
            @calendar = Calendar.find_by(:date => @pto_request.request_date)
        when 'L2'
            @calendar = CalendarL2.find_by(:date => @pto_request.request_date)
        when 'L3'
            @calendar = CalendarL3.find_by(:date => @pto_request.request_date)
        when 'Sup'
            @calendar = CalendarSup.find_by(:date => @pto_request.request_date)
        else 
            @calendar = Calendar.find_by(:date => @pto_request.request_date)
        end

        if @calendar.signed_up_agents.include?(@user.name)
            return redirect_to root_path, notice: "You already have a request for this date"
        end 

        if @user.bank_value < @pto_request.cost
            return  redirect_to root_path, notice: "You do not have enough to make this request"
        end
        
        if @pto_request.save

            update_request_info
            if(current_user.id == @pto_request.user_id)    
                RequestsMailer.with(user: @user, pto_request: @pto_request).requests_email.deliver_now
                return redirect_to root_path
            else 
                @pto_request.reason = @pto_request.reason + " requested by #{current_user.name}"
                @pto_request.save
                RequestsMailer.with(user: @user, pto_request: @pto_request, supervisor: current_user).admin_request_email.deliver_now
                return redirect_to show_user_path(@user)
            end
        else
            return redirect_to root_path, notice: "something went wrong"
        end
    end

    def destroy
        @pto_request = PtoRequest.find(params[:id])
        @user = User.find_by(:id => @pto_request.user_id)
        
        case @user.position
        when 'L1'
            @calendar = Calendar.find_by(:date => @pto_request.request_date)
        when 'L2'
            @calendar = CalendarL2.find_by(:date => @pto_request.request_date)
        when 'L3'
            @calendar = CalendarL3.find_by(:date => @pto_request.request_date)
        when 'Sup'
            @calendar = CalendarSup.find_by(:date => @pto_request.request_date)
        else 
            @calendar = Calendar.find_by(:date => @pto_request.request_date)
        end

        if @pto_request.destroy
            if @pto_request.reason == 'no call / no show'
                return sub_no_call_show
            end

            if @pto_request.reason == 'make up / sick day'
                return sub_make_up_day
            end 

            remove_request_info
            RequestsMailer.with(user: @user, pto_request: @pto_request).delete_request_email.deliver_now
            return redirect_to root_path, notice: "Your request was deleted"
        else
            return redirect_to root_path, notice: "Somthing went wrong"
        end

    end

    def excuse_request
        @pto_request = PtoRequest.find(params[:id])

        if @pto_request == true
            return redirect_to show_user_path(@user), notice: "This request is already excused"
        end

        @user = User.find_by(:id => @pto_request.user_id)
        @user.bank_value += @pto_request.cost

        @pto_request.excused = true
        @pto_request.admin_note = "excused by #{current_user.name}"

        @pto_request.cost = 0
        @pto_request.save
        
        @user.no_call_show -= 1 if @pto_request.reason == "no call / no show"
        @user.make_up_days -= 1 if @pto_request.reason == "make up / sick day"
        @user.save

        RequestsMailer.with(user: @user, pto_request: @pto_request, supervisor: current_user).excuse_request_email.deliver_now
        return redirect_to show_user_path(@user)
    end

    private 
    def post_params
        params.require(:pto_request).permit(:reason, :request_date, :cost, :user_id)
    end

    # update calednar && user with new request info
    def update_request_info
        humanity_request_id = HumanityAPI.create_request(@pto_request, @user)
        HumanityAPI.approve_request(humanity_request_id)
        @pto_request.humanity_request_id = humanity_request_id 
        @pto_request.excused = false
        @pto_request.save

        @calendar.signed_up_total.nil? ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(@user.name)
        
        @calendar.save

        @user.bank_value -= @pto_request.cost
        @user.save

        helpers.update_price(@calendar.date)
    end

    # remove needed info to update the calendar and user appropriately 
    def remove_request_info
        HumanityAPI.delete_request(@pto_request.humanity_request_id)

        @calendar.signed_up_agents.delete(@user.name)
        @calendar.signed_up_total -= 1
        @calendar.save
        helpers.update_price(@calendar.date)

        @user.bank_value += @pto_request.cost
        @user.save
    end

    ## methods used for adding / subtracting no_call_shows for a user
    def add_no_call_show
        humanity_request_id = HumanityAPI.create_request(@pto_request, @user)
        HumanityAPI.approve_request(humanity_request_id)

        @calendar = Calendar.find_by(:date => @pto_request.request_date)
        @pto_request.humanity_request_id = humanity_request_id 
        @pto_request.excused = false
        @pto_request.save

        @calendar.signed_up_total.nil? ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(@user.name)
        
        @calendar.save

        @user.no_call_show.nil? ? @user.no_call_show = 1 : @user.no_call_show += 1;
        @user.save
        
        redirect_to show_user_path(@user)
        helpers.update_price(@calendar.date)
        RequestsMailer.with(user: @user, pto_request: @pto_request).no_call_show_email.deliver_now
    end

    def sub_no_call_show
        HumanityAPI.delete_request(@pto_request.humanity_request_id)
        @pto_request.save

        @calendar.signed_up_agents.delete(@user.name)
        @calendar.signed_up_total -= 1
        @calendar.save

        @user.no_call_show -= 1 unless @user.no_call_show.nil? || @user.no_call_show == 0
        @user.save
        
        redirect_to show_user_path(@user)
        helpers.update_price(@calendar.date)
    end

    ## methods used to add / subtract make_up_day counters
    def add_make_up_day
        humanity_request_id = HumanityAPI.create_request(@pto_request, @user)
        HumanityAPI.approve_request(humanity_request_id)

        @calendar = Calendar.find_by(:date => @pto_request.request_date)
        @pto_request.humanity_request_id = humanity_request_id 
        @pto_request.excused = false
        @pto_request.save

        @calendar.signed_up_total.nil? ? @calendar.signed_up_total = 1 : @calendar.signed_up_total += 1
        @calendar.signed_up_agents.push(@user.name)
        @calendar.save

        @user.make_up_days.nil? ? @user.make_up_days = 1 : @user.make_up_days += 1;
        @user.save
        
        redirect_to show_user_path(@user)
        RequestsMailer.with(user: @user, pto_request: @pto_request).sick_make_up_email.deliver_now
        helpers.update_price(@calendar.date)
    end

    def sub_make_up_day
        HumanityAPI.delete_request(@pto_request.humanity_request_id)
        @pto_request.save
        @calendar = Calendar.find_by(:date => @pto_request.request_date)

        @calendar.signed_up_agents.delete(@user.name)
        @calendar.signed_up_total -= 1
        @calendar.save

        @user.make_up_days -= 1 unless @user.make_up_days.nil? || @user.make_up_days == 0
        @user.save
        
        redirect_to show_user_path(@user)
        helpers.update_price(@calendar.date)
    end
end
