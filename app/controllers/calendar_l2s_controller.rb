class CalendarL2sController < ApplicationController
    before_action :login_required
    def fetch_dates
        render :json => CalendarL2.all.to_json(:except => [:signed_up_agents])
    end
end