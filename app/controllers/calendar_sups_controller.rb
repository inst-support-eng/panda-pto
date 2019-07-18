class CalendarSupsController < ApplicationController
    before_action :login_required
    def fetch_dates
        render :json => CalendarSup.all.to_json(:except => [:signed_up_agents])
    end

    def import
        if params[:file]
            CalendarSup.import(params[:file])
            redirect_to admin_path, notice: "Calendar CSV imported"
        else
            redirect_to admin_path, notice: "Please upload a valid CSV file"
        end
    end

end