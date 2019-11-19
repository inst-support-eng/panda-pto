require 'httparty'

##
# Sharpen APIs for sending sms text messages
class SharpenAPI
  include HTTParty
  base_uri 'https://api.fathomvoice.com'

  ##
  # sends SMS message to array of numbers from Sharpens API
  # params:
  # +message+:: string of message to be used in SMS
  # +user_array+:: array of phone numbers to be sent
  def self.send_sms(message, user_array)
    url = "#{base_uri}/V2/messages/send/"

    headers = {
      'content-type' => 'application/json'
    }

    options = {
      'cKey1' => ENV['CKEY1'],
      'cKey2' => ENV['CKEY2'],
      'toNumbers' => user_array,
      'fromNumber' => ENV['SHARPEN_NUM'],
      'text' => message
    }

    response = SharpenAPI.post(url, headers: headers, body: options.to_json)
    response = JSON.parse(response)

    unless response['status'] == 'Complete'
      return 0
    end

    return 1
  end
end
