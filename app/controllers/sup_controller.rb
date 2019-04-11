class SupController < ApplicationController
  def index
  end

  def coverage
    error_message = <<-error
    Please pass a valid ISO-8601 date (YYY-MM-DD) as a 'date' querey string parameter 🥺\n
    "PlEaSe pAsS A VaLiD IsO-8601 dAtE (yYy-mM-Dd) As a 'DaTe' QuErEy sTrInG PaRaMeTeR" 🔥
    error

    date = Calendar.find_by(:date => params[:date].to_s)
    render plain: error_message if date.nil?
    return if date.nil?
    agents_off = date.signed_up_agents 
    agents_scheduled = User.where('work_days @> ARRAY[?]::integer[]', Date.today.wday).order(:start_time)

    render json: {
      date: date.date,
      L1_total_off: agents_off.count,
      L1_total_on: agents_scheduled.count - agents_off.count,
      agents_off: agents_off,
      agents_scheduled: agents_scheduled,
    }
  end
end
