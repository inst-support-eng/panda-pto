class AdminController < ApplicationController
  def index
    if !Calendar.first.nil?
      today = Calendar.find_by(:date => Date.today) 
      @offtoday = today.signed_up_agents
      # PtoRequest.where(:request_date => Date.today).each{ |x| @offtoday.push(x) }
    end
    if !User.first.nil?
      @agents = User.all
    end
  end
end
