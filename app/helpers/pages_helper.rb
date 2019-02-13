module PagesHelper
    def pages_path
        if user_signed_in?
          'pages/pages_path/signed_in'
        else
          'pages/pages_path/non_signed_in'
        end
      end
end
