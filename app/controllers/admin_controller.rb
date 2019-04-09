class AdminController < ApplicationController
  helper_method :sort_col, :sort_dir
  def index
    today = Calendar.find_by(:date => Date.today) 
    if today.nil? 
      @offtoday = "You may exist outside of spacetime presently. Today does not exist inside the application, please contact the nearest adult." 
    else
      @day = Date.today.wday
      @scheduled = User.where('work_days @> ARRAY[?]::integer[]', Date.today.wday).order(:start_time)
      @offtoday = today.signed_up_agents
    end
    User.any? ? @agents = User.order("#{sort_col} #{sort_dir}") : @agents = []
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

  private 

  def sort_col
    User.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_dir
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end

