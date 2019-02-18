class ImportDateCsv < ApplicationRecord
    require 'csv'
    validates :date, :base_value, presence: true
    
    def self.import(file)
        CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
            # it may be nice to add some error handling here, ie importing already existing values
            # but it may also be nice to easily update values w/ fresh imports
            ImportDateCsv.create! row.to_hash
        end
    end
end
