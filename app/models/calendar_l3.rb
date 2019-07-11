class CalendarL3 < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
        day = find_by(:date => row[:date]) || new
        day.base_value = row[:base_value]
        day.date = row[:date]
        UpdatePrice.update_calendar_item(day)
        day.save
    end
  end

end
