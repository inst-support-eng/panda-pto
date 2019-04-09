module AdminHelper
    def sortable(column, title=nil)
        title ||= column.titleize
        direction = column == sort_col && sort_dir == 'asc' ? 'desc' : 'asc'
        link_to title, :sort => column, :direction => direction
    end
end
