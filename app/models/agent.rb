class Agent < ApplicationRecord
  require 'csv'
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  # ^validating for email uniquiness is *good* but it can create a scenerio where 
  # upating an existing agents name is difficult
  # but i think halding that the same way we are handling date imports is heavy-handed
  # i think the best solution would be adding a manual interface in the admin dashboard !TECHDEBT

  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      Agent.create row.to_hash
    end

    Agent.find_each do |x|
      import = User.where(:email => x.email).first_or_initialize.update_attribute(:name, x.name)
    end

  end
end