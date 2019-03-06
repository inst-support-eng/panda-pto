class DateValuesController < ApplicationController
  def index
  end

  def import
    if params[:file]
      DateValue.import(params[:file])
      DateValue.find_each do |x|
        # !TECHDEBT doesn't update :base_value on import when re-importing existing records
        import = Calendar.where(:date => x.date).first_or_create #.update_attribute(:base_value, x.base_value)
        helpers.update_price(x.date, x.base_value)
        #import.save!
      end
      # likely want to build out more of an admin dashboard
      # so the redirect process will be different !TECHDEBT
      redirect_to root_url, notice: "Date CSV imported"
    else  
      redirect_to(root_url, "Please upload a valid CSV file")
    end
  end
end