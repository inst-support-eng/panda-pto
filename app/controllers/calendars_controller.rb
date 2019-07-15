###
# This controller is used to determine L1 prices
###
class CalendarsController < ApplicationController 
    before_action :login_required
    def show
        @calendar = Calendar.find(params[:id])
    end

    def import
        if params[:file]
            Calendar.import(params[:file])
            # this is really dumb, the update_price helper needs to
            # be moved to make it avaible in the model, quick fix for now
            # ... and maybe update the helper to accept a Calendar object
            # instead of a date !TECHDEBT
            Calendar.find_each do |x|

                helpers.update_price(x)
            end
            redirect_to admin_index_path, notice: "Calendar CSV imported"
        else
            redirect_to admin_index_path, notice: "Please upload a valid CSV file"
        end
    end

    # this will be overriden by csv uploads if the file has the overriden date in it
    def update_base_price
        @calendar = Calendar.find_by(:date => params[:date][:date])
        @calendar.base_value = params[:cost][:cost]

        @calendar.save
        helpers.update_price(@calendar.date)
        redirect_to admin_index_path
    end

    def fetch_dates
        render :json => Calendar.all.to_json(:except => [:signed_up_agents])
    end
end