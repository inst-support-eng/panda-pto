class CreateHumanityRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    puts "job started"
    HumanityAPI.create_request
  end
end
