require 'httparty'

class HumanityRequestsJob < ApplicationJob
  include HTTParty
  queue_as :default

  def get_creds(*args)
    #do something
  end
end
