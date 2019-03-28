class UsersController < ApplicationController
    before_action :find_user, only: %i[update_shift update_admin send_password_reset]
    def show
        if current_user.nil?
            redirect_to login_path
        elsif current_user.admin?
            @user = User.find(params[:id])
        else
            redirect_to root_path, notice: "You do not have access to this resource"
        end
    end

    def current
        render json: current_user
    end

    def update_shift
        @user.ten_hour_shift = !@user.ten_hour_shift
        @user.save

        redirect_to edit_user_password_path
    end

    def update_admin
        @user.admin = !@user.admin
        @user.save
        redirect_to show_user_path(@user) 
    end
    
    def send_password_reset
        @user.send_reset_password_instructions
        redirect_to show_user_path(@user)
    end

    private 
    def find_user
        @user = User.find(params[:user_id])
    end
end
