class CalendarL3sController < ApplicationController
    before_action :login_required
    def fetch_dates
        render :json => CalendarL3.all.to_json(:except => [:signed_up_agents])
    end
    
    def import
        if params[:file]
            CalendarL3.import(params[:file])
            redirect_to admin_index_path, notice: "Calendar CSV imported"
        else
            redirect_to admin_index_path, notice: "Please upload a valid CSV file"
        end
    end

end