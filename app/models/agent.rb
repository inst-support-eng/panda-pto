class Agent < ApplicationRecord
  require 'csv'
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  
  def self.import(file)
    # !TECHDEBT this should be wrapped in some error handling
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all, force_quotes: true}) do |row|
      entry = find_by(:email => row[:email]) || new
      entry.update row.to_hash
      entry.save
    end
    response = HumanityAPI.get_employees
    Agent.find_each do |x|
      User.where(:email => x.email).first_or_initialize do |block|
        generated_password = Devise.friendly_token.first(12)
  
        # math for prorating new hires
        agent_start_date = x.start_date.yday.to_f
        percentage_in_year = agent_start_date/ Date.new(y=Date.today.year, m=12, d=31).yday.to_f
        points_lost = 180 * percentage_in_year
        bank_value = 180-points_lost
        
        # create new users
        user = User.create!(
          :email => block.email, 
          :password => generated_password, 
          :name => x.name, 
          :bank_value => bank_value.round,
          :humanity_user_id => HumanityAPI.set_humanity_id(x.email, response),
          :position => x.position.upcase!,
          :admin => x.admin,
          :on_pip => true,
          :no_call_show => 0,
          :make_up_days => 0,
          :start_date => x.start_date,
          :team => x.team
        )
        RegistrationMailer.with(user: user, password: generated_password).registration_email.deliver_now
        RegistrationMailer.with(user: user).new_employee_email.deliver_now
      end
    # Then itmes should always be updated on import go here
    update_info = User.find_by email: x.email
    update_info.team = x.team
    update_info.start_time = x.start_time
    update_info.end_time = x.end_time
    update_info.work_days = x.work_days.split(",").map(&:to_i) unless x.work_days.nil?
    update_info.position = x.position
    # check if a user who doesn't have a humanity account has one now
    update_info.humanity_user_id = HumanityAPI.set_humanity_id(x.email, response) if update_info.humanity_user_id == 0
    update_info.save

    end
  end
end 
