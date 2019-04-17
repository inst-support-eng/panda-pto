class PtoRequest < ApplicationRecord
  require 'csv'
  belongs_to :user

  def self.import(file)
    CSV.foreach(file.path, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
      agent = User.find_by(:email => row[:email])
      date = Calendar.find_by(:date => row[:date])
      price = row[:shift].to_i
      
      next if agent.nil?
      next if date.nil?
      next if price.nil?
      next if date.signed_up_agents.include?(agent.name)

      PtoRequest.create(
        :request_date => date.date.to_s,
        :cost => price,
        :user_id => agent.id,
        :reason => "Auto imported PTO request. I was pulled from Humanity, please contact your supervisor if I don't belong here.",
        :excused => false
      )
      
      date.signed_up_total == nil ? date.signed_up_total = 1 : date.signed_up_total += 1
      date.signed_up_agents.push(agent.name)
      date.save
      
      agent.bank_value -= price
      agent.save
      

    end
  end

  def self.to_csv()

    data = ['name', 'email', 'request_date', 'cost', 'shoulda_payed', 'reason', 'signed_up_total', 'excused', 'same_day', 'created_at'] 

    CSV.generate(headers: true) do |csv|
      csv << data

      all.each do |pto|
        csv << data.map{ |attr| pto.send(attr) }
      end
      
    end
  end

  def name
    self.user.name
  end
  
  def email
    self.user.email
  end
  
  def same_day
    if self.request_date.to_s == self.created_at.in_time_zone("Mountain Time (US & Canada)").to_s[0,10]
      return TRUE
    else
      return FALSE
    end
  end

  def shoulda_payed
    date = self.request_date
    cal = Calendar.find_by(:date => date)
    self.signed_up_total = 0 if self.signed_up_total == nil
    value = self.signed_up_total + cal.base_value
    shoulda_payed = 0

    scale = { 0  => 0.5, 8  => 1, 15 => 1.5, 21 => 2, 26 => 2.5, 30 => 3, 33 => 3.5, 35 => 4, 36 => 5, 37 => 6, 38 => 7, 39 => 8, 40 => 9 }
    weekend_scale = { 0  => 0.5, 4  => 1, 7 => 1.5, 9 => 2, 10 => 2.5, 11 => 3, 12 => 3.5, 13 => 4, 14 => 5, 15 => 6, 16 => 7, 17 => 8, 18 => 9 }

    if cal.date.wday == 0 || cal.date.wday == 6
      # weekend scaling
      case value
      when weekend_scale.keys[0]..(weekend_scale.keys[1] - 1)
        shoulda_payed = weekend_scale.values[0]
      when weekend_scale.keys[1]..(weekend_scale.keys[2] - 1)
        shoulda_payed = weekend_scale.values[1]
      when weekend_scale.keys[2]..(weekend_scale.keys[3] - 1)
        shoulda_payed = weekend_scale.values[2]
      when weekend_scale.keys[3]..(weekend_scale.keys[4] - 1)
        shoulda_payed = weekend_scale.values[3]
      when weekend_scale.keys[4]..(weekend_scale.keys[5] - 1)
        shoulda_payed = weekend_scale.values[4]
      when weekend_scale.keys[5]..(weekend_scale.keys[6] - 1)
        shoulda_payed = weekend_scale.values[5]
      when weekend_scale.keys[6]..(weekend_scale.keys[7] - 1)
        shoulda_payed = weekend_scale.values[6]
      when weekend_scale.keys[7]..(weekend_scale.keys[8] - 1)
        shoulda_payed = weekend_scale.values[7]
      when weekend_scale.keys[8]..(weekend_scale.keys[9] - 1)
        shoulda_payed = weekend_scale.values[8]
      when weekend_scale.keys[9]..(weekend_scale.keys[10] - 1)
        shoulda_payed = weekend_scale.values[9]
      when weekend_scale.keys[10]..(weekend_scale.keys[11] - 1)
        shoulda_payed = weekend_scale.values[10]
      when weekend_scale.keys[11]..(weekend_scale.keys[12] - 1)
        shoulda_payed = weekend_scale.values[11]
      when weekend_scale.keys[12]..1000
        shoulda_payed = weekend_scale.values[12]
      else
        raise "something went wrong"
      end
    else
      # weekday scaling
      case value
      when scale.keys[0]..(scale.keys[1] - 1)
        shoulda_payed = scale.values[0]
      when scale.keys[1]..(scale.keys[2] - 1)
        shoulda_payed = scale.values[1]
      when scale.keys[2]..(scale.keys[3] - 1)
        shoulda_payed = scale.values[2]
      when scale.keys[3]..(scale.keys[4] - 1)
        shoulda_payed = scale.values[3]
      when scale.keys[4]..(scale.keys[5] - 1)
        shoulda_payed = scale.values[4]
      when scale.keys[5]..(scale.keys[6] - 1)
        shoulda_payed = scale.values[5]
      when scale.keys[6]..(scale.keys[7] - 1)
        shoulda_payed = scale.values[6]
      when scale.keys[7]..(scale.keys[8] - 1)
        shoulda_payed = scale.values[7]
      when scale.keys[8]..(scale.keys[9] - 1)
        shoulda_payed = scale.values[8]
      when scale.keys[9]..(scale.keys[10] - 1)
        shoulda_payed = scale.values[9]
      when scale.keys[10]..(scale.keys[11] - 1)
        shoulda_payed = scale.values[10]
      when scale.keys[11]..(scale.keys[12] - 1)
        shoulda_payed = scale.values[11]
      when scale.keys[12]..1000
        shoulda_payed = scale.values[12]
      else
        raise "something went wrong"
      end
    end
    
    
    if self.user.ten_hour_shift?
      shoulda_payed = shoulda_payed * 10
    else
      shoulda_payed = shoulda_payed * 8
    end
    return shoulda_payed
    
  end

end
