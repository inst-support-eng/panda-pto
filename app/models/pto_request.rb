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
    data = ['name', 'email', 'request_date', 'cost', 'signed_up_total', 'excused', 'created_at'] 
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

end
