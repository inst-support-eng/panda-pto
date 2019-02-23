class DateValue < ApplicationRecord
  require 'csv'
  validates :date, :base_value, presence: true

  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      DateValue.create! row.to_hash
    end
    # delete all duplicate records
    grouped = all.group_by{|x| [x.date]}
    grouped.values.each do |duplicates|
      most_recent = duplicates.pop # pop keeps last item , shift would keep first
      # delete all duplicates
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed

      # push values to calendar table


    end
  end
end
