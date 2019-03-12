# frozen_string_literal: true

require 'httparty'

class HumanityAPI
  include HTTParty
  base_uri 'https://www.humanity.com'

  def self.create_request(request, user)
    access_token = get_token
    url = "#{base_uri}/api/v2/leaves?access_token=#{access_token}"
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    options = {
      'employee' => user.humanity_user_id.to_s,
      'leavetype' => '304060', # vaction PTO request id in humanity
      'start_date' => request.request_date.to_s,
      'end_date' => request.request_date.to_s,
      'reason' => request.reason.to_s
    }

    response = HumanityAPI.post(url, headers: headers, body: options)
    response['data']['id']
  end

  def self.approve_request(request_id)
    access_token = get_token
    url = "#{base_uri}/api/v2/leaves/#{request_id}?access_token=#{access_token}"
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    options = { 'status' => 1 }

    response = HumanityAPI.put(url, headers: headers, body: options)
    response
  end

  def self.delete_request(request_id)
    access_token = get_token
    url = "#{base_uri}/api/v2/leaves/#{request_id}?access_token=#{access_token}"

    response = HumanityAPI.delete(url)
    response
  end

  def self.get_employees
    access_token = get_token
    url = "#{base_uri}/api/v2/employees?access_token=#{access_token}"
    puts url
    response = HumanityAPI.get(url)
    response['data']
  end

  def self.get_token
    url = "#{base_uri}/oauth2/token.php"
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    options = {
      'grant_type' => 'password',
      'client_secret' => ENV['HUMANITY_CLIENT_SECRET'],
      'client_id' => ENV['HUMANITY_CLIENT_ID'],
      'password' => ENV['HUMANITY_PASSWORD'],
      'username' => ENV['HUMANITY_USERNAME']
    }

    response = HumanityAPI.post(url, headers: headers, body: options)
    access_token = response.parsed_response['access_token']
    access_token
  end
end
