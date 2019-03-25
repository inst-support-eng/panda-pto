class Agent < ApplicationRecord
  require 'csv'
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  
  
  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all, force_quotes: true}) do |row|
      Agent.create row.to_hash
    end
    response = HumanityAPI.get_employees
    Agent.find_each do |x|
      # this block is for all code that should only execute when first creating the user? 
      # https://stackoverflow.com/questions/21190339/rails-first-or-initialize-by-one-value-but-add-more-values-if-created
      # It will execute block for new record only.
      User.where(:email => x.email).first_or_initialize do |block|
        generated_password = Devise.friendly_token.first(12)
  
        user = User.create!(
          :email => block.email, 
          :password => generated_password, 
          :name => x.name, 
          :bank_value => 90, 
          :humanity_user_id => HumanityAPI.set_humanity_id(x.email, response)
          # shouldn't need to set team / shift information yet
          # but fr some reason it appears like we do?
          # also need to figure out how to import arrays... maybe
        )
        RegistrationMailer.with(user: user, password: generated_password).registration_email.deliver_now
      end
    # Then itmes should always be updated on import go here
    update_info = User.find_by email: x.email 
    update_info.team = x.team
    update_info.start_time = x.start_time
    update_info.end_time = x.end_time
    update_info.work_days = x.work_days.split(",").map(&:to_i)
    # check if a user who doesn't have a humanity account has one now
    update_info.humanity_user_id = HumanityAPI.set_humanity_id(x.email, response) if update_info.humanity_user_id == 0
    update_info.save

    end

  end
end 