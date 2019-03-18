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

        redirect_to '/'
    end
end