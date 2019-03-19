class AdminController < ApplicationController
  def index
    @offtoday = []
    @offtoday = PtoRequest.where(:request_date => Date.today)
    @agents = User.all
  end
end
