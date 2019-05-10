class User < ApplicationRecord
  has_many :pto_requests

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.import(file)
    response = HumanityAPI.get_employees
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      agent = find_by(:email => row[:email]) || new
     
      # should only update when first created
      if agent.new_record?
        bank_value = 180 - (180 * (Date.parse(row[:start_date]).yday.to_f/ Date.new(y=Date.today.year, m=12, d=31).yday.to_f))
  
        agent.password = Devise.friendly_token.first(12)
        agent.bank_value = bank_value
        agent.humanity_user_id = HumanityAPI.set_humanity_id(row[:email], response)
        agent.on_pip = true
        agent.no_call_show = 0
      end
      # should always update on import
      unless row[:email].nil? || row[:name].nil?
        agent.email = row[:email]
        if row[:start_date].nil? 
          agent.start_date = 1970-01-01
        else
          agent.start_date = row[:start_date]
        end
        agent.name = row[:name]
        agent.position = row[:position].upcase!
        agent.admin = row[:admin] 
        agent.team = row[:team] 
        agent.start_time = row[:start_time] 
        agent.end_time = row[:end_time] 
        agent.work_days = row[:work_days].split(",").map(&:to_i) unless row[:work_days].nil?
        agent.humanity_user_id = HumanityAPI.set_humanity_id(row[:email], response) if agent.humanity_user_id == 0
        agent.on_pip = 0 if agent.on_pip.nil?
      end
      
      agent.save
    end

  end

      
end
