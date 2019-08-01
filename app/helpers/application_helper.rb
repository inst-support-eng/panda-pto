require 'navigation_helper.rb'
require 'pages_helper.rb'

module ApplicationHelper
  include NavigationHelper
  include PagesHelper
  include AdminHelper
end