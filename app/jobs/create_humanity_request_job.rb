class CreateHumanityRequestJob < ApplicationJob
  queue_as :default

  def perform(user)
    puts "#{user.name} made a request job got kicked off"
  end
end
