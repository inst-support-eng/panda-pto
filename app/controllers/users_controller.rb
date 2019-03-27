class UsersController < ApplicationController
    def show
        @user = User.find(params[:id])
    end

    def current
        render json: current_user
    end

    def update_shift
        @user = User.find(params[:user_id])
        @user.ten_hour_shift = !@user.ten_hour_shift
        @user.save

        redirect_to edit_user_password_path
    end

    def update_admin
        @user = User.find(params[:user_id])
        
    end
    
    def send_password_reset
        @user = User.find(params[:user_id])
        @user.send_reset_password_instructions
        redirect_to show_user_path(@user)
    end
end
