class DeleteHumanityRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    puts "#{user.name} deleted a pto request"
  end
end
