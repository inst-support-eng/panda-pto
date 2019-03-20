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

    response = HumanityAPI.get_employees

    # itterate over imported data
    # !TECHDEBT adding in a status bar would be nice
    Agent.find_each do |x|
      # check if user already exists
      # if not create user and send a password
      User.where(:email => x.email).first_or_initialize do |block|
        generated_password = Devise.friendly_token.first(12)
        humanity_user_id = response.select { |res| res['email'] == x.email}
        
        user = User.create!(:email => block.email, :password => generated_password, :name => x.name, :bank_value => 90, :humanity_user_id => humanity_user_id[0]['id'])
        RegistrationMailer.with(user: user, password: generated_password).registration_email.deliver_now
      end
    end

  end
end 