require 'httparty'

class HumanityAPI
    include HTTParty
    base_uri 'https://www.humanity.com'

    def self.create_request
        access_token = get_token
        url = "#{base_uri}/api/v2/leaves?access_token=#{access_token}"
        options = {
            "employee" => 3475050
            "leavetype" => 328495
            "start_date" => 2017-12-01
            "end_date" => 2017-12-02
            "is_hourly" => false
            "reason" => string
        }
    end

    def self.approve_request
        # status=1
    end

    def self.delete_request
        # https://www.humanity.com/api/v2/leaves/2621938?access_token=xxxxxxx
    end

    def self.get_employees
        access_token = get_token
        url = "#{base_uri}/api/v2/employees?access_token=#{access_token}"
        puts url
        response = HumanityAPI.get(url)
        response["data"]
    end

    def self.get_token
        url = "#{base_uri}/oauth2/token.php"
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded'}
        options = {
            'grant_type' => 'password',
            'client_secret' => ENV['HUMANITY_CLIENT_SECRET'],
            'client_id' => ENV['HUMANITY_CLIENT_ID'],
            'password' => ENV['HUMANITY_PASSWORD'],
            'username' => ENV['HUMANITY_USERNAME']
        }

        response = HumanityAPI.post(url, :headers => headers, :body => options)
        access_token = response.parsed_response['access_token']
        access_token
    end
end