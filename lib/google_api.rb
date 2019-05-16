# auth documenation found here: https://cloud.google.com/docs/authentication/production
# sheets documentation found here: https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get
class GoogleAPI
  require 'google/apis/sheets_v4'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'


  def self.get_csv(sheet_id, cell_range)
    # accepts a google sheet id and a cell range
    # returns a temporary csv file

    # google-api auth
    scope = ['https://www.googleapis.com/auth/spreadsheets']
    authorization = Google::Auth.get_application_default(scope)
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = authorization
    # retrieve google sheet data
    response = service.get_spreadsheet_values(sheet_id, cell_range).to_h.fetch(:values)
    # return temp csv
    temp_csv = Tempfile.open(["/", ".csv"])
    CSV.open(temp_csv, "w", :headers => true) do |csv|
      response.each { |row| csv << row }
    end
    return temp_csv
  end

end 