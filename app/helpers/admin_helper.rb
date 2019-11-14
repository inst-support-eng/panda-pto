###
# Helper for admin path
module AdminHelper
  # makes users table sortable
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_col && sort_dir == 'asc' ? 'desc' : 'asc'
    link_to title, sort: column, direction: direction
  end
end
