class ApplicationController < ActionController::Base

    def login_required
        redirect_to login_path if current_user.blank?
      end
end
