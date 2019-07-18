class CalendarsController < ApplicationController 
    before_action :login_required
    def show
        @calendar = Calendar.find(params[:id])
    end

    def import
        if params[:file]
            Calendar.import(params[:file])
            redirect_to admin_path, notice: "Calendar CSV imported"
        else
            redirect_to admin_path, notice: "Please upload a valid CSV file"
        end
    end

    # this will be overriden by csv uploads if the file has the overriden date in it
    def update_base_price
        @calendar = Calendar.find_by(:date => params[:date][:date])
        @calendar.base_value = params[:cost][:cost]

        @calendar.save
        UpdatePrice.update_calendar_item(@calendar)
        redirect_to admin_path
    end

    def fetch_dates
        render :json => Calendar.all.to_json(:except => [:signed_up_agents])
    end
end