class AgentsController < ApplicationController
  def index
  end

  def import
    if params[:file]
      Agent.import(params[:file])
      # likely want to build out more of an admin dashboard
      # so the redirect process will be different !TECHDEBT
      redirect_to root_url, notice: "Agents CSV imported"
    else  
      redirect_to(root_url, "Please upload a valid CSV file")
    end
  end
end