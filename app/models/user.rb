class User < ApplicationRecord
  has_many :pto_requests

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

# import users from csv        
  def self.import(file)
    response = HumanityAPI.get_employees
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      agent = find_by(:email => row[:email]) || new
     
      # should only update when first created
      if agent.new_record?
        # this math is for figuring out the users pto balance for their start year
        if Date.parse(row[:start_date]).year == Date.today.year
          bank_value = 180 - (180 * (Date.parse(row[:start_date]).yday.to_f/ Date.new(y=Date.today.year, m=12, d=31).yday.to_f))
        else
          bank_value = 180
        end
        # this math gives users balance for the year following their hire date 
        # minus 45 is due to q1 does not vest for new users if that is their hire quarter 
        # they would just get the points for the year and then start vesting with everyone else the following year
        vesting_quarter = (Legalizer.quarter(Date.today) * 45) - 45 
        bank_value += vesting_quarter
        generated_password = Devise.friendly_token.first(12)

        agent.password = generated_password
        agent.bank_value = bank_value
        agent.humanity_user_id = HumanityAPI.set_humanity_id(row[:email], response)
        agent.on_pip = true
        agent.no_call_show = 0
        agent.is_deleted = FALSE
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
        agent.position = row[:position].downcase.capitalize
        agent.admin = row[:admin] 
        agent.team = row[:team] 
        agent.start_time = row[:start_time] 
        agent.end_time = row[:end_time] 
        agent.work_days = row[:work_days].split(",").map(&:to_i) unless row[:work_days].nil?
        agent.humanity_user_id = HumanityAPI.set_humanity_id(row[:email], response) if agent.humanity_user_id == 0
        agent.on_pip = 0 if agent.on_pip.nil?
        agent.is_deleted = row[:is_deleted]
        agent.is_deleted = 0 if agent.is_deleted.nil?
      end
      
      if agent.new_record?
        RegistrationMailer.with(user: agent, password: generated_password).registration_email.deliver_now
        RegistrationMailer.with(user: agent).new_employee_email.deliver_now
        agent.save
      else
        agent.save
        #deletes any upcoming requests for deleted users
        if agent.is_deleted?
          SoftDelete.delete_future_requesets(agent)
          agent.update(:password => SecureRandom.hex)
        end
      end
    end
  end    

# import users from humanity
  def self.humanity_import
    humanity_users = HumanityAPI.get_employees
    deleted_users = HumanityAPI.get_deleted_employees

    humanity_users.each do |u|
      if u['schedules'].any? && (u['schedules']['1836499'] || u['schedules']['1836500'] ||  u['schedules']['1836500'])
        agent = find_by(:email => u['email']) || new 
        if agent.new_record?
          if Date.parse(u['work_start_date']).year == Date.today.year
            # this math is for figuring out the users pto balance for their start year 
            bank_value = 180 - (180 * (Date.parse(u['work_start_date']).yday.to_f/ Date.new(y=Date.today.year, m=12, d=31).yday.to_f))
            # this math gives users balance for the year following their hire date 
            # minus 45 is due to q1 does not vest for new users if that is their hire quarter 
            # they would just get the points for the year and then start vesting with everyone else the following year
            bank_value += (Legalizer.quarter(Date.today) * 45) - 45 
          else  
            bank_value = 180
            bank_value += (Legalizer.quarter(Date.today) * 45) - 45 
          end
          agent.email = u['email'] 
          generated_password = Devise.friendly_token.first(12)
          agent.password = generated_password
          agent.bank_value = bank_value
          agent.humanity_user_id = u['id']
          agent.on_pip = true
          agent.no_call_show = 0
        end

        agent.name = u['name']
        agent.position = 'L1'
        agent.admin = false
        agent.start_date = u['work_start_date']
        agent.team = u['skills'].values[0] unless u['skills'].empty?
        start_time = u['custom']['35718']['value'] 
        end_time = u['custom']['35719']['value']

        unless start_time.nil?
          Time.zone = 'Mountain Time (US & Canada)'
          time = Time.zone.parse(start_time).in_time_zone('UTC')
          hour = time.hour
          if hour < 10
            start_time = '0%d:00' %[hour] + 'Z'
          else
            start_time = '%d:00' %[hour] + 'Z'
          end
        end
        
        unless end_time.nil?
          Time.zone = 'Mountain Time (US & Canada)'
          time = Time.zone.parse(end_time).in_time_zone('UTC')
          hour = time.hour
          if hour < 10
            end_time = '0%d:00' %[hour] + 'Z'
          else
            end_time = '%d:00' %[hour] + 'Z'
          end
        end

        agent.start_time = start_time
        agent.end_time = end_time
        shift_difference = (end_time.to_i - start_time.to_i).abs
        24 - shift_difference == 8 ? agent.ten_hour_shift = false : agent.ten_hour_shift = true

        work_days = []
        if u['custom']['35708']['toggle'] == '1'
          work_days.push(0)
        end
        if u['custom']['35711']['toggle'] == '1'
          work_days.push(1)
        end
        if u['custom']['35712']['toggle'] == '1'
          work_days.push(2)
        end
        if u['custom']['35713']['toggle'] == '1'
          work_days.push(3)
        end
        if u['custom']['35714']['toggle'] == '1'
          work_days.push(4)
        end
        if u['custom']['35715']['toggle'] == '1'
          work_days.push(5)
        end
        if u['custom']['35716']['toggle'] == '1'
          work_days.push(6)
        end

        agent.work_days = work_days unless work_days.nil?
        agent.humanity_user_id = u['id']
        agent.on_pip = 0 if agent.on_pip.nil?
        
        if agent.new_record?
          RegistrationMailer.with(user: agent, password: generated_password).registration_email.deliver_now
          RegistrationMailer.with(user: agent).new_employee_email.deliver_now
          agent.save
        else
          agent.save
        end 
      end
    # check for deleted users
    deleted_users.each do |d|
      agent = find_by(:email => d['email'])
      next if agent.nil?
      SoftDelete.delete_future_requesets(agent)
      agent.update(:is_deleted => 1, :password => SecureRandom.hex)
    end
  end 

end
