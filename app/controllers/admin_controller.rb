class AdminController < ApplicationController
  def index
    today = Calendar.find_by(:date => Date.today) 
    @offtoday = today.signed_up_agents
    # PtoRequest.where(:request_date => Date.today).each{ |x| @offtoday.push(x) }
    @agents = User.all
  end
end
