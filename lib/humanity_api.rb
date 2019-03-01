require 'httparty'

class HumanityAPI
    include HTTParty
    @base_url = 'https://www.humanity.com'

    def self.get_token
        url = "#{@base_url}/oauth2/token.php"
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

    def self.create_request
        access_token = get_token
        puts access_token
    end

    def self.approve_request
    end

    def self.delete_request
    end

    def self.get_employees
        url = "#{@base_url}/api/v2/employees?access_token=#{get_token}"
        response = HumanityAPI.get(url)
    end
end