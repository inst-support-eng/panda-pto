class CalendarsController < ApplicationController
    def show
        @calendar = Calendar.find(params[:id])
    end

    def fetch_dates
        calendar_dates = Calendar.all

        render json: {calendar_dates: calendar_dates}
    end
end