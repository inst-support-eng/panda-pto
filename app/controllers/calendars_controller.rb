class CalendarsController < ApplicationController
    def show
        @calendar = Calendar.find(params[:id])
    end

    def fetch_dates
        render json: Calendar.all
    end
end