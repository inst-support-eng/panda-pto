class ImportDateCsvController < ApplicationController
  def index
    #@date_value = ImportDateCsv.all
  end

  def import
    if params[:file]
      ImportDateCsv.import(params[:file])
      redirect_to root_url, notice: "Date CSV imported"
    else  
      redirect_to(root_url, "Please upload a valid CSV file")
    end
  end
end
