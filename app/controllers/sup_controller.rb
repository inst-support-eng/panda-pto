class SupController < ApplicationController
  before_action :login_required
  
  def index
  end

  def coverage
    # prolly dont need this, but prolly doesnt hurt
    # error_message = <<-error
    # Please pass a valid ISO-8601 date (YYYY-MM-DD) as a 'date' querey string parameter 🥺\n
    # "PlEaSe pAsS A VaLiD IsO-8601 dAtE (yYyy-mM-Dd) As a 'DaTe' QuErEy sTrInG PaRaMeTeR" 🔥
    # error
    
    # render plain: error_message if date.nil?
    # return if date.nil?

    params[:date].nil? ? date = Calendar.find_by(:date => Date.today) : date = Calendar.find_by(:date => params[:date].to_s)

    agents_off = date.signed_up_agents 
    agents_scheduled = User.where('work_days @> ARRAY[?]::integer[]', Date.today.wday).order(:start_time)

    render json: {
      date: date.date,
      l1_total_off: agents_off.count,
      l1_total_on: agents_scheduled.count - agents_off.count,
      agents_off: agents_off,
      agents_scheduled: agents_scheduled
    }
  end
end
