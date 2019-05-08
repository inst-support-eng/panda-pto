class CalendarSupsController < ApplicationController
    before_action :login_required
    def fetch_dates
        render :json => CalendarSup.all.to_json(:except => [:signed_up_agents])
    end

    def import
        if params[:file]
            CalendarL2.import(params[:file])
            CalendarL2.find_each do |x|
                helpers.update_price(x.date)
                # !TECHDEBT update_price helper will need to be modified once we know 
                # alternitive scaling for different teams
            end
            redirect_to admin_index_path, notice: "Calendar CSV imported"
        else
            redirect_to admin_index_path, notice: "Please upload a valid CSV file"
        end
    end

end