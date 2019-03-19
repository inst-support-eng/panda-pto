class DateValuesController < ApplicationController
  def index
  end

  def import
    if params[:file]
      DateValue.import(params[:file])

      DateValue.find_each do |x|
        @import = Calendar.where(:date => x.date).first_or_create
        @import.base_value = x.base_value
        @import.save
        helpers.update_price(x.date)
      end
      redirect_to root_url, notice: "Date CSV imported"
    else  
      redirect_to(root_url, "Please upload a valid CSV file")
    end
  end
end