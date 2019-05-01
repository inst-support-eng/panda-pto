class CalendarSupsController < ApplicationController
    before_action :login_required
    def fetch_dates
        render :json => CalendarSup.all.to_json(:except => [:signed_up_agents])
    end
end