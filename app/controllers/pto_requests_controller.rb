###
# this controller is for PTO requests made by end user and admins
###
class PtoRequestsController < ApplicationController
    before_action :login_required
    # export all PTO requests from db
    def export
        @export_pto = PtoRequest.all
        respond_to do |format|
            format.csv { send_data @export_pto.to_csv }
        end
    end

    # import existing requests into the system
    def import_request
        if params[:file]
            # the PtoRequests are created in the model
            PtoRequest.import(params[:file])
            # since the requests already exist, get all dates pto requests where created for
            # and run just those dates through UpdatePrice
            # prevents us from updating the same calendar object multiple times
            dates = []
            CSV.foreach(params[:file].path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
                dates.push(row[:date])
            end
            dates.uniq.each { |x| UpdatePrice.update_calendar_item(x) }
            redirect_to root_url, notice: "PTO requests imported!"
        else
            redirect_to root_url, alert: "Weep Womp. Please upload a valid CSV file"
        end
    end
    
    #export single users requests
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
            return redirect_to root_path, alert: "You're PTO is currently restricted, please talk to your supervisor"
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

        # set signed_up_total on a ptorequest object when it's created
        # equal to the signed_up_total of the associated calendar object
        # prior to the request being made
        @pto_request.signed_up_total = @calendar.signed_up_total

        if @calendar.signed_up_agents.include?(@user.name)
            return redirect_to root_path, alert: "You already have a request for this date"
        end 

        if @user.bank_value < @pto_request.cost
            return  redirect_to root_path, alert: "You do not have enough to make this request"
        end

        if @pto_request.cost == -1
            if @user.ten_hour_shift?
                @pto_request.cost = @calendar.current_price * 10
            else 
                @pto_request.cost = @calendar.current_price * 8 
            end
        end

        if @pto_request.save
            update_request_info
            check_long_requests

            bank_split = Legalizer.split_year(@user)
            year_balance = 0
            if @pto_request.request_date.year == Date.today.year
                year_balance = bank_split[0]
            else
                year_balance = bank_split[1]
            end 

            if(current_user.id == @pto_request.user_id)
                RequestsMailer.with(user: @user, pto_request: @pto_request, year_balance: year_balance).requests_email.deliver_now
                return redirect_to root_path
            else 
                @pto_request.reason = @pto_request.reason + " requested by #{current_user.name}"
                @pto_request.save
                RequestsMailer.with(user: @user, pto_request: @pto_request, supervisor: current_user).admin_request_email.deliver_now
                return redirect_to show_user_path(@user)
            end
        else
            return redirect_to root_path, alert: "something went wrong"
        end
    end

    def soft_delete
        @pto_request = PtoRequest.find(params[:id])
        @user = @pto_request.user
        # disallow regular users from deleting pto requests they don't own
        unless current_user.admin == false || current_user.position != "Sup" || @user != current_user
            return  redirect_back(fallback_location: root_path), alert: "You do not have sufficent privlages to delete this request."
        end
        # disallow regular users from deleting past pto requests
        if @user == current_user && @pto_request.request_date < Date.today
            return  redirect_back(fallback_location: root_path), alert: "You do not have sufficent privlages to delete this request."
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


        if @pto_request.reason == 'no call / no show'
            sub_no_call_show
        end

        if @pto_request.reason == 'make up / sick day'
            sub_make_up_day
        end 

        # mark request as soft deleted
        @pto_request.update(:is_deleted => 1)
        # query all requests for the day, made after the deleted request
        @future_requests = PtoRequest.where(["request_date = ? and created_at > ?", @pto_request.request_date, @pto_request.created_at]).to_a
        # parital refund requests if avalible
        UpdatePrice.update_pto_requests(@future_requests)

        remove_request_info

        RequestsMailer.with(user: @user, pto_request: @pto_request).delete_request_email.deliver_now
        return redirect_back(fallback_location: root_path), notice: "Your request was deleted"
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

            return redirect_to root_path, alert: "Somthing went wrong"
        end

    end

    def excuse_request
        @pto_request = PtoRequest.find(params[:id])

        if @pto_request == true
            return redirect_to show_user_path(@user), alert: "This request is already excused"
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

    # check to see if there are more than 4 consective days off in a row for a user
    def check_long_requests
        if @user.pto_requests.find_by(:request_date => @pto_request.request_date + 1.day) || @user.pto_requests.find_by(:request_date => @pto_request.request_date - 1.day)
            all_requests = @user.pto_requests.order('request_date ASC')
            dates = []

            all_requests.each do |req|
                dates.push(req.request_date)
            end

            prev = dates.first
            requests = dates.slice_before { |d| prev, prev2 = d, prev; prev2 + 1.day != d }.to_a
            longest_request = requests.each_index.max_by { |i| requests[i].size }

            if requests[longest_request].count >= 4
                RequestsMailer.with(:user => @user, :requests => requests[longest_request]).long_requests_email.deliver_now
            end
        end
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

        if @user.bank_value <= 0
            RequestsMailer.with(:user => @user).zero_credit_email.deliver_now
        elsif @user.bank_value <= 8
            RequestsMailer.with(:user => @user).eight_credits_email.deliver_now
        end

        UpdatePrice.update_calendar_item(@calendar)
    end

    # remove needed info to update the calendar and user appropriately 
    def remove_request_info
        @user.bank_value += @pto_request.cost
        @user.save

        @calendar.signed_up_agents.delete(@user.name)
        @calendar.signed_up_total -= 1
        @calendar.save
        UpdatePrice.update_calendar_item(@calendar)
        HumanityAPI.delete_request(@pto_request.humanity_request_id)
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
        UpdatePrice.update_calendar_item(@calendar)
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
        
        UpdatePrice.update_calendar_item(@calendar)
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
        UpdatePrice.update_calendar_item(@calendar)
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
        
        UpdatePrice.update_calendar_item(@calendar)
    end
end
