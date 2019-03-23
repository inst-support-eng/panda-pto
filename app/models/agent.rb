class Agent < ApplicationRecord
  require 'csv'
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  
  def set_humanity_id(email)
    humanity_user_id = response.select { |res| res['email'] == email}
    if humanity_user_id.empty?
        humanity_user_id = 0
        # prevents a user without a humanity account from derailing an import
    else
        humanity_user_id = humanity_user_id[0]['id']
    end
  end 
  
  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
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
          :humanity_user_id => set_humanity_id(x.email)
          # shouldn't need to set team / shift information yet
        )
        RegistrationMailer.with(user: user, password: generated_password).registration_email.deliver_now
      end
    # Then itmes should always be updated on import go here
    update_info = User.where(:email => x.email)
    update_info.team = x.team
    update_info.start_time = x.start_time
    update_info.end_time = x.end_time
    udpate_info.work_days = x.work_days
    # check if a user who doesn't have a humanity account has one now
    update_info.humanity_user_id = set_humanity_id(x.email) if update_info.humanity_user_id == 0

    end

  end
end 