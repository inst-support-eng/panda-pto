class AdminController < ApplicationController
  def index
    today = Calendar.find_by(:date => Date.today) 
    if today.nil? 
      @offtoday = "You may exist outside of spacetime presently. Today does not exist inside the application, please contact the nearest adult." 
    else 
      @offtoday = today.signed_up_agents 
    end
    
    User.any? ? @agents = [] : @agents = User.all
  end
end

