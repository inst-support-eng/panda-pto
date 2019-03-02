class CreateHumanityRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    
  end
end
