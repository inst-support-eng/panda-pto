class CalendarsController < ApplicationController
    before_action :login_required
    def show
        @calendar = Calendar.find(params[:id])
    end

    def fetch_dates
        render json: Calendar.all
    end
end