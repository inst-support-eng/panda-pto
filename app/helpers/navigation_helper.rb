module NavigationHelper

    def collapsible_links_partial_path
      if user_signed_in?
        'layouts/navigation/collapsible_elements/signed_in_links'
      else
        'layouts/navigation/collapsible_elements/non_signed_in_links'
      end
    end
    
end