class RegistrationsController < Devise::RegistrationsController

    def edit
      require 'date'
      @workdays = ""
      current_user.work_days.each do |day|
        @workdays << "#{Date::DAYNAMES[day]}, "
      end
      @shift_start = Time.parse(current_user.start_time).in_time_zone("Mountain Time (US & Canada)").strftime("%I:%M %p")
      @shift_end = Time.parse(current_user.end_time).in_time_zone("Mountain Time (US & Canada)").strftime("%I:%M %p")
      @bank_split = Legalizer.split_year(current_user)
    end

    private
  
    def sign_up_params
      params.require(:user).permit( :name, 
                                    :email, 
                                    :password, 
                                    :password_confirmation)
    end
  
    def account_update_params
      params.require(:user).permit( :name, 
                                    :email, 
                                    :password, 
                                    :password_confirmation, 
                                    :current_password)
    end
  end