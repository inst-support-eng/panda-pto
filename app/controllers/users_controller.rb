###
# this controller is for adjusting users table values
###
class UsersController < ApplicationController
    before_action :find_user, only: %i[destroy update_shift update_admin update_pip send_password_reset]
    def show
        if current_user.nil?
            redirect_to login_path
        elsif current_user.admin? || current_user.position == "Sup"
            @user = User.find(params[:id])
            @workdays = ""
            @user.work_days.each do |day|
                @workdays << "#{Date::DAYNAMES[day]}, "
            end
            @shift_start = Time.parse(@user.start_time).in_time_zone("Mountain Time (US & Canada)").strftime("%I:%M %p") unless @user.start_time.nil?
            @shift_end = Time.parse(@user.end_time).in_time_zone("Mountain Time (US & Canada)").strftime("%I:%M %p") unless @user.end_time.nil?

            @bank_split = Legalizer.split_year(@user)
        else
            redirect_to root_path, alert: "You do not have access to this resource"
        end
    end

    def destroy
        @user.pto_requests.each do |request|
            request.destroy
        end

        if @user.destroy 
            redirect_to admin_path
        else 
            redirect_to show_user_path(@user), alert: "something went wrong"
        end
    end 

    # returns current user as json
    def current
        @user = User.find(current_user.id)
        
        respond_to do |format|
            format.json {render :json => @user.to_json(:include => :pto_requests)}
        end
    end

    # update 8 / 10 hour shift
    def update_shift
        @user.ten_hour_shift = !@user.ten_hour_shift
        @user.save

        redirect_to show_user_path(@user) 
    end

    # toggles admin
    def update_admin
        @user.admin = !@user.admin
        @user.save
        redirect_to show_user_path(@user) 
    end

    # toggles pip, which allows user to make requests
    def update_pip
        @user.on_pip = !@user.on_pip
        @user.save
        redirect_to show_user_path(@user) 
    end
    
    def send_password_reset
        @user.send_reset_password_instructions
        redirect_to show_user_path(@user)
    end

    def import
        if params[:file]
            User.import(params[:file])
            redirect_to admin_path, notice: "Agents CSV imported!"
        else
            redirect_to admin_path, alert: "Please upload a valid CSV file"
        end
    end

    def soft_delete
        @user = User.find(params[:id])
        #updating the user's password also kills active sessions
        @user.update(:is_deleted => 1, :password => SecureRandom.hex)
        @user.pto_requests.where('request_date > ?', Date.today).destroy_all
        redirect_to show_user_path(@user)
    end

    def restore_user
        @user = User.find(params[:id])
        if @user.nil?
            render plain: "No user found with an id of #{params[:id]}"
        elsif @user.is_deleted == false
            not_deleted =  <<-error
            User: #{@user.name}, Email: #{@user.email}, ID: #{@user.id}
            is not not deleted
            error
            render plain: not_deleted
        else
            @user.update(:is_deleted => 0)
            redirect_to show_user_path(@user), notice: "User restored"
        end
    end

    private 
    def find_user
        @user = User.find(params[:user_id])
    end
end
