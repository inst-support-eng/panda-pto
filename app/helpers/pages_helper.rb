##
# helper to direct logged in users to the calendar/ sidebar
##
module PagesHelper
  def pages_path
    if user_signed_in?
      'pages/pages_path/calendar'
    else
      'pages/pages_path/non_signed_in'
    end
  end
end
