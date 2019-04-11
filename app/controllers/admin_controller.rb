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

  private 

  def sort_col
    User.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_dir
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end

